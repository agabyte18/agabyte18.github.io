# Objective: Configure replication for HA and execute a manual failover

In this objective, you'll build a two-node MySQL 8 replication pair from scratch using plain `docker` commands for convenience. You'll prove that your configuration works, simulate an outage, manually fail over to the replica, and then bring back the old primary instance as a replica of the new primary. Follow each step in order. Each step gives you exactly one command to run.

1. Click **Open Environment** once available to access the lab environment.

2. Select **Terminal Emulator** from the dock to open a terminal.

3. Create a convenience alias:

   ```
   alias docker="sudo docker"
   ```

   You'll need `sudo` to run the `docker` commands in your lab environment. Having to type `sudo` each time will get very old very quickly. This alias makes your life a little easier.

4. Create a dedicated Docker network for the replication pair:

   ```
   docker network create mysql-repl-net
   ```

   This network ensures the two MySQL containers you're about to launch can find and reach each other by container name instead of by IP address.

5. Launch the source instance:

   ```
   docker run -d \
     --name mysql-source \
     --network mysql-repl-net \
     --hostname mysql-source \
     -p 3307:3306 \
     -e MYSQL_ROOT_PASSWORD=RootPass123 \
     mysql:8.4 \
     --server-id=1 \
     --gtid-mode=ON \
     --enforce-gtid-consistency=ON \
     --log-bin=mysql-bin \
     --log-replica-updates=ON \
     --binlog-format=ROW
   ```

   Your first MySQL 8.4 instance, `mysql-source`, is now started on the network you just created. Port 3306 in the container maps to port 3307 on the host.
   Enabling GTID mode and binary logging right on the command line starts MySQL in the desired state without having to provide a config file. Giving the instance a `server-id` of `1` ensures the instance is uniquely identified in the replication topology.

6. Launch the replica:

   ```
   docker run -d \
     --name mysql-replica \
     --network mysql-repl-net \
     --hostname mysql-replica \
     -p 3308:3306 \
     -e MYSQL_ROOT_PASSWORD=RootPass123 \
     mysql:8.4 \
     --server-id=2 \
     --gtid-mode=ON \
     --enforce-gtid-consistency=ON \
     --log-bin=mysql-bin \
     --log-replica-updates=ON \
     --binlog-format=ROW
   ```

   Your second instance, `mysql-replica`, is now running on the same network, mapped to host port 3308, with server-id 2 to make it distinct from the source instance.

7. Create the MySQL replication user on the source:

   ```
   docker exec -i mysql-source mysql -uroot -pRootPass123 <<'SQL'
   CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'ReplPass123';
   GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
   FLUSH PRIVILEGES;
   SQL
   ```

   Every replica needs credentials to pull changes from the source. This command creates a dedicated `repl` user on `mysql-source` and grants it only the `REPLICATION SLAVE` privilege — nothing more. You don't need
   to record a binlog file or position anywhere here, because GTIDs let MySQL figure out the replica's starting point automatically.

8. Point the replica at the source and start replication:

   ```
   docker exec -i mysql-replica mysql -uroot -pRootPass123 <<'SQL'
   CHANGE REPLICATION SOURCE TO
     SOURCE_HOST='mysql-source',
     SOURCE_PORT=3306,
     SOURCE_USER='repl',
     SOURCE_PASSWORD='ReplPass123',
     SOURCE_AUTO_POSITION=1,
     SOURCE_SSL=1;
   START REPLICA;
   SQL
   ```

   This command tells `mysql-replica` where to find its source. `SOURCE_AUTO_POSITION=1` is the key setting here — it tells MySQL to use GTIDs to negotiate the starting point instead of a manual log file and offset. `SOURCE_SSL=1` uses the self-signed TLS certificate the server generates for itself out of the box because MySQL's default `caching_sha2_password` auth plugin will not authenticate a replication connection that is not encrypted. Finally, `START REPLICA` kicks off replication.

9. Verify the replica's replication threads are running:

   ```
   docker exec -i mysql-replica mysql -uroot -pRootPass123 -e "SHOW REPLICA STATUS\G" \
     | grep -E "Replica_IO_Running|Replica_SQL_Running|Last_IO_Error|Last_SQL_Error"
   ```

   If both `Replica_IO_Running` and `Replica_SQL_Running`
   read `Yes`, your replica is live and streaming from the source.

10. Create the demo database, table, and seed rows on the source:

    ```
    docker exec -i mysql-source mysql -uroot -pRootPass123 <<'SQL'
    CREATE DATABASE IF NOT EXISTS demo;
    USE demo;
    CREATE TABLE IF NOT EXISTS course_notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    note VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    INSERT INTO course_notes (note) VALUES
    ('hello from the source'),
    ('replication is LIVE'),
    ('Pluralsight labs are the best.');
    SQL
    ```

    Talk is cheap, so it's necessary to prove that data actually flows by creating a `demo` database and `course_notes` table directly on the `mysql-source` instance, making sure to insert a couple of rows in the new table. You will look for this data on the replica in the next step.

11. Read the same data back from the replica:

    ```
    docker exec -i mysql-replica mysql -uroot -pRootPass123 -e "SELECT * FROM demo.course_notes;"
    ```

    Et voila! Replication is doing its job. Your configuration works as expected.

12. Confirm the replica is fully caught up:

    ```
    docker exec -i mysql-replica mysql -uroot -pRootPass123 -e "SHOW REPLICA STATUS\G" \
      | grep -E "Replica_IO_Running|Replica_SQL_Running|Seconds_Behind_Source"
    ```

    A value of `0` for `Seconds_Behind_Source` indicates that your replica database is fully caught up and synchronized with the primary (source) database.

13. Simulate a real outage on the source:

    ```
    docker stop mysql-source
    ```

    Instead of just pretending the source is gone, this command actually takes it down the same way a primary instance would fail in the real world. This means, the failover you perform in the next step will be against a genuinely unreachable node.

14. Confirm the source container is no longer running:

    ```
    docker ps --filter "name=mysql-source"
    ```

    Filtering the running-containers list for `mysql-source` returns nothing, confirming that any processes attempting to write the primary instance will be out of luck — it's time to fail over.

15. Promote the replica to a standalone, writable primary:

    ```
    docker exec -i mysql-replica mysql -uroot -pRootPass123 <<'SQL'
    STOP REPLICA;
    RESET REPLICA ALL;
    SET GLOBAL read_only = OFF;
    SET GLOBAL super_read_only = OFF;
    SQL
    ```

    Failing-over by hand means telling the replica to stop trying to be a replica and start acting as a standalone, writable primary. You've now stopped
    replication on the replica, cleared its replication configuration entirely, and turned off read-only mode so that the server will accept direct writes.

16. Verify that read-only mode is off:

    ```
    docker exec -i mysql-replica mysql -uroot -pRootPass123 \
      -e "SELECT @@read_only AS read_only, @@super_read_only AS super_read_only;"
    ```

    A value of `0` for both fields confirms that read-only mode is now turned off for the new primary.

17. Write new data directly to the promoted primary:

    ```
    docker exec -i mysql-replica mysql -uroot -pRootPass123 \
      -e "INSERT INTO demo.course_notes (note) VALUES ('Written directly to the NEWLY PROMOTED PRIMARY');"
    ```

    This is the real test of your failover — inserting a row directly into what used to be a read-only replica. Before promotion, this move would have been rejected.

18. Bring the old primary back online:

    ```
    docker start mysql-source
    ```

    For a satisfying ending, you've brought back the original source so you can turn it into a replica of your new primary. Because you did a `docker stop` rather than a `docker rm` earlier, the old primary's data directory is intact and ready to restart.

19. Take a fresh snapshot of the demo database from the new primary:

    ```
    docker exec mysql-replica sh -c \
      'mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --databases demo --single-transaction --set-gtid-purged=ON' \
      > /tmp/mysql-repl-demo-resync.sql
    ```

    Because you promoted the replica while the old primary was down, their GTID histories have diverged, so you can't just point the old primary at the new one and expect it to pick up where it left off. This is why you've just taken a consistent `mysqldump` of the `demo` database from the new primary, `mysql-replica`, with `--set-gtid-purged=ON` so that the dump carries the GTID position it needs to resume correctly.

20. Wipe the old primary's replication and GTID history:

    ```
    docker exec -i mysql-source mysql -uroot -pRootPass123 <<'SQL'
    STOP REPLICA;
    RESET REPLICA ALL;
    RESET BINARY LOGS AND GTIDS;
    SQL
    ```

    `mysql-source`'s old replication configuration and its
    entire GTID history will no longer apply once you reload it from a fresh snapshot of the new primary, which is why you've just cleared it.

21. Load the fresh snapshot into the old primary:

    ```
    docker exec -i mysql-source mysql -uroot -pRootPass123 < /tmp/mysql-repl-demo-resync.sql
    ```

    This command restores the dump you took from `mysql-replica` onto `mysql-source`, giving it both the current data and the correct GTID from which to resume replication.

22. Point the old primary at the new primary and start replication:

    ```
    docker exec -i mysql-source mysql -uroot -pRootPass123 <<'SQL'
    CHANGE REPLICATION SOURCE TO
      SOURCE_HOST='mysql-replica',
      SOURCE_PORT=3306,
      SOURCE_USER='repl',
      SOURCE_PASSWORD='ReplPass123',
      SOURCE_AUTO_POSITION=1,
      SOURCE_SSL=1;
    START REPLICA;
    SQL
    ```

    This command configures `mysql-source` the same way you configured the original replica back in step 8, but this time, the topology has reversed, and the old primary is now the replica.

23. Verify the rejoined node's replication threads are running:

    ```
    docker exec -i mysql-source mysql -uroot -pRootPass123 -e "SHOW REPLICA STATUS\G" \
      | grep -E "Replica_IO_Running|Replica_SQL_Running|Last_IO_Error|Last_SQL_Error"
    ```

    A value of `Yes` on both running-state fields confirms that the old primary, `mysql-source`, has successfully rejoined the topology as a replica of `mysql-replica`.

24. Write a new row to the new primary:

    ```
    docker exec -i mysql-replica mysql -uroot -pRootPass123 \
      -e "INSERT INTO demo.course_notes (note) VALUES ('Full Circle - rEpLiCaTiOn ReVeRsEd.');"
    ```

25. Confirm that the new row was replicated to the old primary:

    ```
    docker exec -i mysql-source mysql -uroot -pRootPass123 -e "SELECT * FROM demo.course_notes;"
    ```

    WONDERFUL! You can see the new row on the old primary (new replica).

26. Remove the network, both containers, and the stale snapshot file:

    ```
    docker rm -f mysql-source mysql-replica && docker network rm mysql-repl-net && rm -fv /tmp/mysql-repl-demo-resync.sql
    ```

In this objective, you started with a healthy source/replica pair, simulated an outage, and finished-up with a manual failover that reversed your initial topology. In the next objective, you'll learn to recover from a disaster using a physical backup and recovery strategy.
