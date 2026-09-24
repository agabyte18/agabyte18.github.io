# Objective: Backup and Restore from a Physical Backup

In this objective, you'll take a hot physical backup of the host's entire MySQL 8.0 server using the industry-standard Percona XtraBackup 8.0. You'll then proceed to destroy the server's entire data directory. Finally, you'll rebuild the whole server from backup. Follow each step in order. Each step gives you exactly one command to run.

1. In case you closed the **terminal emulator** from the previous objective, you'll need to recreate the convenience alias:

   ```
   alias mysql="sudo mysql"
   ```

   MySQL `root` still logs in through `auth_socket`, so every `mysql` command has to run under `sudo`. The alias takes care of that for you.

2. Confirm that Percona XtraBackup is installed:

   ```
   xtrabackup --version
   ```

   XtraBackup is installed directly on this host, right next to MySQL. The version it prints starts with `8.0`, which matches the server's major version. XtraBackup 8.0 only backs up MySQL 8.0.

3. Create a separate directory for your backups:

   ```
   sudo install -d -m 700 /backups
   ```

   Storing backups near live data is a recipe for disaster. A backup stored next to the data it protects will die with that data in the event of a catastrophe. Keeping backups outside the data directory ensures they survive the disaster you're about to cause. On a real server, `/backups` would be a different disk, or better yet a different machine. Mode `700` keeps everyone but `root` out, because a backup holds every row and every account on the server.

4. Create the demo database, table, and seed rows:

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
   ('Hello from MySQL'),
   ('I love Pluralsight.'),
   ('Pluralsight labs are the best.');
   SQL
   ```

   You need some data worth protecting, so this command creates a `demo` database and a `course_notes` table and inserts a few rows.

5. Read the data you just inserted:

   ```
   mysql -e "SELECT * FROM demo.course_notes;"
   ```

   Take note of these three rows. They're the baseline you'll expect to see again after the restore.

6. Take a physical backup of the entire instance:

   ```
   sudo xtrabackup --backup --target-dir=/backups/full
   ```

   XtraBackup copies the InnoDB files at the file level while the server keeps running (a hot backup). It connects to the server through the local socket only to coordinate a brief backup lock and record the binary log position. `sudo` does double work here. The data files belong to the `mysql` user, so reading them requires `root`. Also, because XtraBackup runs as the operating system's `root` user, `auth_socket` logs it in as MySQL `root` with no password. When you see `completed OK!`, the backup is in `/backups/full`. You can safely ignore the `Allocated tablespace ID 1 for sys/sys_config` warning that appears along the way.

7. Inspect what the backup contains:

   ```
   sudo ls -l /backups/full
   ```

   This is a copy of the entire instance, not just your `demo` database. `mysql.ibd` holds the data dictionary (the table definitions for every schema on the server) along with the system tables, such as user accounts. Next to it are the system tablespace (`ibdata1`), the undo tablespaces (`undo_001`, `undo_002`), the current binary log, and a directory per schema, including `demo/`. The `xtrabackup_*` files are XtraBackup's own metadata, such as the log sequence numbers in the backup.

8. Write a new row after the backup:

   ```
   mysql -e "INSERT INTO demo.course_notes (note) VALUES ('Written AFTER backup - this row WILL BE LOST.');"
   ```

   This row is not in your backup. Keep an eye out for it after the restore.

9. Simulate a catastrophic failure by taking down the server:

   ```
   sudo systemctl stop mysql
   ```

   In the previous objective, you stopped the server and brought it back with its data intact. Not this time. The server is down, and the next step makes sure its data never comes back.

10. Destroy the data directory:

    ```
    sudo rm -rf /var/lib/mysql
    ```

    And now the data is gone too. Every data file, every binary and redo log, and the data dictionary itself have been wiped out. Without a backup, this is a very bad day. I've seen at least one DBA fired for this in real life.

11. Confirm that only the backup is left:

    ```
    sudo ls -d /var/lib/mysql /backups/full
    ```

    `ls` complains that `/var/lib/mysql` doesn't exist and lists `/backups/full`, the only survivor. Everything you need to rebuild the server is in that directory.

12. Prepare the backup:

    ```
    sudo xtrabackup --prepare --target-dir=/backups/full
    ```

    Because the server kept running while its files were being copied, the raw backup is not yet consistent. The prepare phase replays the redo log that XtraBackup captured during the backup and rolls back any uncommitted transactions, leaving a data directory that MySQL can start from cleanly. Again, look for `completed OK!`, and ignore the same `sys/sys_config` warning you saw during the backup.

13. Create a fresh, empty data directory:

    ```
    sudo install -d -o mysql -g mysql -m 700 /var/lib/mysql
    ```

    It helps to think of this new directory as the replacement disk in the new database instance you're building. `install -d` recreates it with the same owner (`mysql`) and permissions (`700`) that Ubuntu's MySQL package gave the original.

14. Copy the prepared backup into the new data directory:

    ```
    sudo xtrabackup --copy-back --target-dir=/backups/full --datadir=/var/lib/mysql
    ```

    `--copy-back` puts every file from the backup back where the server expects to find it. This flag refuses to write into a non-empty data directory, which is why you created a fresh one in the previous step. Ubuntu's MySQL configuration doesn't spell out `datadir`, so you name it yourself with `--datadir`. Without it, XtraBackup stops with `datadir must be specified`.

15. Grant ownership of the restored files to the `mysql` user:

    ```
    sudo chown -R mysql:mysql /var/lib/mysql
    ```

    The copy-back ran as `root`, so every restored file is owned by `root`. The MySQL server runs as the `mysql` user and can't read those files, so it would refuse to start. Fixing ownership after every copy-back is the habit to keep.

16. Start the MySQL server on the restored data:

    ```
    sudo systemctl start mysql
    ```

    This is the same service you stopped in step 9, now starting on a data directory rebuilt from the backup. You don't need a separate wait step. Ubuntu's `mysql` service tells systemd when the server is ready for connections, so `systemctl start` does not return your prompt until then.

17. Confirm that your data survived the disaster:

    ```
    mysql -e "SELECT * FROM demo.course_notes;"
    ```

    WONDERFUL! Your three original rows are back, on a server rebuilt from nothing but a backup. Even your login works because the user accounts, including `root` and its `auth_socket` setting, all came back with the backup. If you look closely though, the row you wrote in step 8 is missing. A backup only restores the server to the moment it was taken. Anything written after that point is lost.

18. Remove the demo database, the backup, and the metadata file left by XtraBackup in the data directory:

    ```
    mysql -e "DROP DATABASE demo;" && sudo rm -rf /backups /var/lib/mysql/xtrabackup_info
    ```

In this objective, you took a hot physical backup of an entire MySQL instance, destroyed its data directory, and rebuilt the server from the backup. You also saw the limitation of a backup on its own. Everything written after the backup was lost. In the next objective, you'll close that gap with point-in-time recovery.

