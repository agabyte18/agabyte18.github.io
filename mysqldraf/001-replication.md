# Objective: Configure replication for HA and execute a manual failover

In this objective, you will build a two-node MySQL 8.0 replication pair from scratch on a single Ubuntu host, using the default MySQL server install, plus a second instance you'll create by hand. You'll prove that your configuration works, simulate an outage, manually fail over to the replica, and then bring back the old primary instance as a replica of the new primary. Follow each step in order. Each step gives you exactly one command to run.

1. Click **Open Environment** once available to access the lab environment.

2. Select **Terminal Emulator** from the dock to open a terminal.

3. Confirm that the preinstalled MySQL server is running:

   ```
   sudo systemctl status mysql --no-pager
   ```

   Look for `active (running)`. This packaged server, managed by systemd, is your source instance. Throughout this objective, your source instance will be referred to as `mysql-source`. It stores its data in `/var/lib/mysql` and listens on port 3306. Like every Ubuntu MySQL install, its `root` account uses the `auth_socket` plugin, so running the `mysql` client as the operating system's `root` user logs you in as MySQL `root` without a password. The operating system has already verified your identity.

4. Create a convenience alias:

   ```
   alias mysql="sudo mysql"
   ```

   Because of `auth_socket`, every `mysql` command in this lab has to run as the operating system's `root` user, which means `sudo`. Having to type `sudo` each time will get very old very quickly. This alias makes your life a little easier: from now on, typing `mysql` runs `sudo mysql` for you. Like any alias, it lasts only for this terminal session.

5. Add replication settings to the source instance's configuration:

   ```
   sudo tee /etc/mysql/mysql.conf.d/replication.cnf <<'EOF'
   [mysqld]
   server-id                = 1
   gtid_mode                = ON
   enforce_gtid_consistency = ON
   log_bin                  = mysql-bin
   log_replica_updates      = ON
   binlog_format            = ROW
   EOF
   ```

   Ubuntu's MySQL reads every `.cnf` file in `/etc/mysql/mysql.conf.d/`, so a small drop-in file is the cleanest way to change the server's settings without editing the packaged `mysqld.cnf`. Enabling GTID mode and binary logging gives the instance everything it needs to act as a replication source. Giving it a `server-id` of `1` ensures the instance is uniquely identified in the replication topology.

6. Restart the source so the new settings take effect:

   ```
   sudo systemctl restart mysql
   ```

   GTID mode and the binary log name are read at startup, so the server needs a restart to pick them up.

7. Verify the source's new settings:

   ```
   mysql -e "SELECT @@server_id, @@gtid_mode, @@log_bin_basename;"
   ```

   You should see server ID `1`, GTID mode `ON`, and a binary log path ending in `mysql-bin`. Notice that `mysql` needs no `-u` or `-p`: that's `auth_socket` at work.

8. Create a configuration file for the replica instance:

   ```
   sudo tee /etc/mysql/replica.cnf <<'EOF'
   [mysqld]
   user                     = mysql
   datadir                  = /var/lib/mysql-replica
   port                     = 3307
   socket                   = /var/lib/mysql-replica/mysql.sock
   pid-file                 = /var/lib/mysql-replica/mysql.pid
   log-error                = /var/log/mysql/replica-error.log
   mysqlx                   = OFF
   plugin-load-add          = auth_socket.so
   server-id                = 2
   gtid_mode                = ON
   enforce_gtid_consistency = ON
   log_bin                  = mysql-bin
   log_replica_updates      = ON
   binlog_format            = ROW
   EOF
   ```

   Your second instance, which will be referred to as `mysql-replica` throughout this objective, runs on the same host, so everything that could collide with the source has to be different: data directory, port, socket and PID file, and error log. The X Protocol plugin is turned off so it doesn't fight the source for port 33060. `plugin-load-add` loads the `auth_socket` plugin, which Ubuntu registered for the source when it installed MySQL but which a brand-new instance doesn't have. The socket and PID file live inside the replica's data directory on purpose. systemd deletes `/run/mysqld` whenever the source stops, and you'll stop the source later in this lab. The replication settings match the source's, except for `server-id`, which is `2` to make it distinct. This file sits outside `mysql.conf.d`, so the source never reads it.

9. Allow the replica's data directory in the MySQL AppArmor profile:

   ```
   sudo tee -a /etc/apparmor.d/local/usr.sbin.mysqld <<'EOF'
   /var/lib/mysql-replica/ r,
   /var/lib/mysql-replica/** rwk,
   EOF
   ```

   Ubuntu confines `mysqld` with an AppArmor profile that only lets it touch `/var/lib/mysql` and a few other known paths. Any `mysqld` process is confined by that profile, including the one you're about to start. The profile includes this `local` file for site-specific additions, so appending two rules here grants the replica access to its own data directory without editing the packaged profile.

10. Reload the AppArmor profile:

    ```
    sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld
    ```

    AppArmor doesn't notice file changes on its own. Reloading the profile makes the new rules take effect right away.

11. Create the replica's data directory:

    ```
    sudo install -d -o mysql -g mysql -m 750 /var/lib/mysql-replica
    ```

    `install -d` creates the directory with the `mysql` user as owner in a single command. The server runs as `mysql`, so it needs to own the directory to write into it.

12. Initialize the replica's data directory:

    ```
    sudo mysqld --defaults-file=/etc/mysql/replica.cnf --initialize-insecure
    ```

    This command creates the system tables for a brand-new instance and then exits. `--defaults-file` makes `mysqld` read only the replica's configuration and ignore the rest of `/etc/mysql`. `--initialize-insecure` creates a `root@localhost` account with an empty password. This is temporary: you'll soon switch it to `auth_socket`.

13. Start the replica instance:

    ```
    sudo mysqld --defaults-file=/etc/mysql/replica.cnf --daemonize
    ```

    `--daemonize` starts the server in the background and hands your prompt back. systemd doesn't manage this instance. It's just a process you started by hand, and you'll shut it down by hand when you clean up.

14. Wait until the replica is ready for connections:

    ```
    until sudo grep -q "ready for connections.*port: 3307" /var/log/mysql/replica-error.log; do sleep 2; done; echo "MySQL is ready"
    ```

    A server needs a moment to start up, and connecting too early will result in an error. The server announces itself with `ready for connections` on `port: 3307`. This command checks the replica's error log every two seconds until that line appears. When you see `MySQL is ready`, you're good to go.

15. Switch the replica's `root` account to operating-system authentication:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock \
      -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH auth_socket;"
    ```

    Now `root` on the replica works exactly like `root` on the source: `mysql` logs you in and nobody can log in with a password. From here on, `--socket` is how you choose the instance. Without `--socket`, `mysql` talks to the source. To talk to the replica, you must use the replica's socket by specifying `--socket`.

16. Create the MySQL replication user on the source:

    ```
    mysql <<'SQL'
    CREATE USER IF NOT EXISTS 'repl'@'%' IDENTIFIED BY 'ReplPass123';
    GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
    FLUSH PRIVILEGES;
    SQL
    ```

    Every replica needs credentials to pull changes from the source. This command creates a dedicated `repl` user on `mysql-source` and grants it only the `REPLICATION SLAVE` privilege, nothing more. Unlike `root`, the replica logs in over the network, so this user needs a password. You don't need to record a binlog file or position anywhere here because GTIDs help MySQL figure out the replica's starting point automatically.

17. Point the replica at the source and start replication:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock <<'SQL'
    CHANGE REPLICATION SOURCE TO
      SOURCE_HOST='127.0.0.1',
      SOURCE_PORT=3306,
      SOURCE_USER='repl',
      SOURCE_PASSWORD='ReplPass123',
      SOURCE_AUTO_POSITION=1,
      SOURCE_SSL=1;
    START REPLICA;
    SET GLOBAL super_read_only = ON;
    SQL
    ```

    This command tells `mysql-replica` where to find its source, which in this case is port 3306 on the same host. `SOURCE_AUTO_POSITION=1` is the key setting here. It tells MySQL to use GTIDs to negotiate the starting point instead of a manual log file and offset. `SOURCE_SSL=1` uses the self-signed TLS certificate the server generates for itself out of the box. MySQL's default `caching_sha2_password` auth plugin won't authenticate a replication connection over plain text unless you set up RSA key exchange instead, so encryption is the simplest route. `START REPLICA` kicks off replication. Finally, `super_read_only` (which also turns on `read_only`) makes the replica refuse direct writes from every client, even `root`. Changes arriving from the source through replication are exempt, so they keep flowing.

18. Verify the replica's replication threads are running:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock -e "SHOW REPLICA STATUS\G" \
      | grep -E "Replica_IO_Running|Replica_SQL_Running|Last_IO_Error|Last_SQL_Error"
    ```

    If both `Replica_IO_Running` and `Replica_SQL_Running` read `Yes`, your replica is live and streaming from the source. If `Replica_IO_Running` still says `Connecting`, the replica hasn't finished its first connection yet. Wait a few seconds and run the command again.

19. Create the demo database, table, and seed rows on the source:

    ```
    mysql <<'SQL'
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

    Talk is cheap, so it's necessary to prove that data actually flows by creating a `demo` database and `course_notes` table directly on the `mysql-source` instance, making sure to insert a few rows in the new table. You will look for this data on the replica in the next step.

20. Read the same data back from the replica:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock -e "SELECT * FROM demo.course_notes;"
    ```

    Et voila! Replication is doing its job. Your configuration works as expected.

21. Confirm the replica is fully caught up:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock -e "SHOW REPLICA STATUS\G" \
      | grep -E "Replica_IO_Running|Replica_SQL_Running|Seconds_Behind_Source"
    ```

    A value of `0` for `Seconds_Behind_Source` indicates that your replica database is fully caught up and synchronized with the primary (source) database. If you see a small nonzero number, the replica is still applying the rows you just wrote. Run the command again after a moment.

22. Simulate a real outage on the source:

    ```
    sudo systemctl stop mysql
    ```

    Instead of just pretending the source is gone, this command actually takes it down. A real failure would be less polite than a clean shutdown, but from the replica's point of view the result is the same: its source is unreachable. This means the failover you perform next will be against a genuinely unreachable node.

23. Confirm the source is no longer running:

    ```
    systemctl is-active mysql
    ```

    `inactive` confirms that any processes attempting to write to the primary instance will be out of luck. It's time to fail over.

24. Promote the replica to a standalone, writable primary:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock <<'SQL'
    STOP REPLICA;
    RESET REPLICA ALL;
    SET GLOBAL read_only = OFF;
    SET GLOBAL super_read_only = OFF;
    SQL
    ```

    Failing over by hand means telling the replica to stop trying to be a replica and start acting as a standalone, writable primary. You've now stopped replication on the replica, cleared its replication configuration entirely, and turned off read-only mode so that the server will accept direct writes.

25. Verify that read-only mode is off:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock \
      -e "SELECT @@read_only AS read_only, @@super_read_only AS super_read_only;"
    ```

    A value of `0` for both fields confirms that read-only mode is now turned off for the new primary.

26. Write new data directly to the promoted primary:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock \
      -e "INSERT INTO demo.course_notes (note) VALUES ('Written directly to the NEWLY PROMOTED PRIMARY');"
    ```

    This is the real test of your failover: inserting a row directly into what used to be a read-only replica. Before promotion, this move would have been rejected.

27. Bring the old primary back online:

    ```
    sudo systemctl start mysql
    ```

    For a satisfying ending, you've brought back the original source so you can turn it into a replica of your new primary. Stopping a service doesn't touch its data, so the old primary's data directory in `/var/lib/mysql` is intact and ready to restart.

28. Take a fresh snapshot of the demo database from the new primary:

    ```
    sudo mysqldump --socket=/var/lib/mysql-replica/mysql.sock \
      --databases demo --single-transaction --set-gtid-purged=ON \
      > /tmp/mysql-repl-demo-resync.sql
    ```

    Because you promoted the replica while the old primary was down, their GTID histories have diverged, so you can't just point the old primary at the new one and expect it to pick up where it left off. This is why you've just taken a consistent `mysqldump` of the `demo` database from the new primary, `mysql-replica`, with `--set-gtid-purged=ON` so that the dump carries the GTID position it needs to resume correctly. `mysqldump` warns that a partial dump includes the GTIDs of all transactions. That's exactly what you want here, so you can ignore the warning.

29. Wipe the old primary's replication and GTID history:

    ```
    mysql <<'SQL'
    STOP REPLICA;
    RESET REPLICA ALL;
    RESET MASTER;
    SQL
    ```

    `mysql-source`'s old replication configuration and its entire GTID history will no longer apply once you reload it from a fresh snapshot of the new primary. That's why you've just cleared them. In MySQL 8.0, `RESET MASTER` is the statement that deletes the binary logs and empties the GTID history.

30. Load the fresh snapshot into the old primary:

    ```
    mysql < /tmp/mysql-repl-demo-resync.sql
    ```

    This command restores the dump you took from `mysql-replica` onto `mysql-source`, giving it both the current data and the correct GTID position from which to resume replication.

31. Point the old primary at the new primary and start replication:

    ```
    mysql <<'SQL'
    CHANGE REPLICATION SOURCE TO
      SOURCE_HOST='127.0.0.1',
      SOURCE_PORT=3307,
      SOURCE_USER='repl',
      SOURCE_PASSWORD='ReplPass123',
      SOURCE_AUTO_POSITION=1,
      SOURCE_SSL=1;
    START REPLICA;
    SQL
    ```

    This command configures `mysql-source` the same way you configured the original replica back in step 17. This time, though, the topology has reversed: the old primary is now the replica, pulling from port 3307. The `repl` user already exists on `mysql-replica` because it replicated there when you created it in step 16.

32. Verify the rejoined node's replication threads are running:

    ```
    mysql -e "SHOW REPLICA STATUS\G" \
      | grep -E "Replica_IO_Running|Replica_SQL_Running|Last_IO_Error|Last_SQL_Error"
    ```

    A value of `Yes` on both running-state fields confirms that the old primary, `mysql-source`, has successfully rejoined the topology as a replica of `mysql-replica`. As before, if `Replica_IO_Running` says `Connecting`, give it a few seconds and check again.

33. Write a new row to the new primary:

    ```
    mysql --socket=/var/lib/mysql-replica/mysql.sock \
      -e "INSERT INTO demo.course_notes (note) VALUES ('Full Circle - rEpLiCaTiOn ReVeRsEd.');"
    ```

34. Confirm that the new row was replicated to the old primary:

    ```
    mysql -e "SELECT * FROM demo.course_notes;"
    ```

    WONDERFUL! You can see the new row on the old primary (new replica).

35. Shut down the replica instance, remove everything the lab added, and return the source to its original configuration:

    ```
    sudo mysqladmin --socket=/var/lib/mysql-replica/mysql.sock shutdown \
      && mysql -e "STOP REPLICA; RESET REPLICA ALL; DROP DATABASE demo; DROP USER 'repl'@'%'; RESET MASTER;" \
      && sudo rm -rf /var/lib/mysql-replica /var/log/mysql/replica-error.log /etc/mysql/replica.cnf \
           /etc/mysql/mysql.conf.d/replication.cnf /tmp/mysql-repl-demo-resync.sql \
      && sudo sed -i '/mysql-replica/d' /etc/apparmor.d/local/usr.sbin.mysqld \
      && sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.mysqld \
      && sudo systemctl restart mysql \
      && sudo sh -c 'rm -f /var/lib/mysql/mysql-bin.* /var/lib/mysql/*-relay-bin.*'
    ```

In this objective, you started with a healthy source/replica pair, simulated an outage, and finished up with a manual failover that reversed your initial topology. In the next objective, you'll learn to recover from a disaster using a physical backup and recovery strategy.

