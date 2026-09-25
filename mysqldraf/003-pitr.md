# Objective: Restore a Logical Backup and Verify the Recovery Point

In this objective, you will take a logical backup of a single table with `mysqldump`, keep writing to it, and then accidentally drop it. The backup alone would cost you every row written after it, the same gap you saw in the previous objective. So you'll restore the backup and then replay the server's binary log right up to the moment before the mistake. This is called point-in-time recovery. Follow each step in order. Each step gives you exactly one command to run.

1. In case you closed the **terminal emulator** from the previous objective, you'll need to recreate the convenience alias:

   ```
   alias mysql="sudo mysql"
   ```

2. Confirm that binary logging is on:

   ```
   mysql -e "SELECT @@log_bin, @@log_bin_basename, @@binlog_format;"
   ```

   Point-in-time recovery depends entirely on the binary log, the server's record of every change it makes, in order. MySQL 8.0 turns it on by default. You should see `1`, a path ending in `/var/lib/mysql/binlog`, and the `ROW` format, which records the actual rows each statement changed.

3. Create a separate directory for your backups:

   ```
   sudo install -d -m 700 /backups
   ```

   Just like the previous objective, backups live outside the data directory, and mode `700` keeps everyone but `root` out.

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

5. Take a logical backup of just the `course_notes` table:

   ```
   sudo mysqldump --single-transaction --source-data=2 \
     --result-file=/backups/course_notes.sql demo course_notes
   ```

   Unlike the physical backup in the previous objective, a logical backup is a file of SQL statements that rebuild the table. `mysqldump` reads the rows through the server and writes them out as SQL `INSERT` statements. Naming a database and a table backs up only that table. `--single-transaction` reads everything from one consistent snapshot so that writes aren't blocked while the rows are copied. `--source-data=2` records the binary log file and position that match that snapshot, as a comment in the file. To capture that position exactly, `mysqldump` holds a global read lock for a moment at the start. That position is where point-in-time recovery will pick up. `--result-file` has `mysqldump` write the file itself, running as `root`, because your own shell can't write into `/backups`.

6. Look inside the backup:

   ```
   sudo grep -E "CHANGE MASTER TO|CREATE TABLE|INSERT INTO" /backups/course_notes.sql
   ```

   Three lines tell the whole story. The commented-out `CHANGE MASTER TO` line holds the binary log file (`MASTER_LOG_FILE`) and position (`MASTER_LOG_POS`) of the backup. MySQL 8.0's `mysqldump` still writes this older syntax, even though you asked for it with `--source-data`. `CREATE TABLE` rebuilds the table, and a single `INSERT INTO` puts your three rows back.

7. Keep working. Write two more rows after the backup:

   ```
   mysql -e "INSERT INTO demo.course_notes (note) VALUES ('Written AFTER backup #4'), ('Written AFTER backup #5');"
   ```

   These rows aren't in the backup. In the previous objective, rows like these were lost for good. This time, the binary log has them.

8. Make a mistake. Drop the table:

   ```
   mysql -e "DROP TABLE demo.course_notes;"
   ```

   One wrong command, and the table and all five rows are gone. Mistakes like this, not just failed hardware, are a classic reason for a point-in-time recovery.

9. Confirm that the table is gone:

   ```
   mysql -e "SELECT * FROM demo.course_notes;"
   ```

   `ERROR 1146` tells you that `demo.course_notes` doesn't exist.

10. Save the backup's binary log file name in a shell variable:

    ```
    BINLOG=$(sudo grep -oP "MASTER_LOG_FILE='\K[^']+" /backups/course_notes.sql) && echo "Binary log file: $BINLOG"
    ```

    This pulls the file name out of the comment you saw in step 6 and keeps it in the `$BINLOG` shell variable, so that the next steps can use it without you typing it by hand. Like the alias, the variable lasts only for this terminal session.

11. Save the backup's binary log position in another shell variable:

    ```
    START_POS=$(sudo grep -oP "MASTER_LOG_POS=\K[0-9]+" /backups/course_notes.sql) && echo "Start position: $START_POS"
    ```

    Every change to `course_notes` before this position is already in the backup. Everything after it is what you need to replay.

12. List every change the server logged after the backup:

    ```
    mysql -e "SHOW BINLOG EVENTS IN '$BINLOG' FROM $START_POS;"
    ```

    Each row is one event in the binary log, with its starting position in `Pos`. Every transaction begins with an `Anonymous_Gtid` event. Find your two rows: a `Write_rows` event inside a transaction that ends with `Xid`. Right after that comes the mistake: an `Anonymous_Gtid` event followed by a `Query` event whose `Info` reads `DROP TABLE`. You want to replay everything up to that `DROP`, and nothing from it onward.

13. Save the position where the `DROP` transaction starts:

    ```
    STOP_POS=$(mysql -N -e "SHOW BINLOG EVENTS IN '$BINLOG' FROM $START_POS;" | grep -B1 "DROP TABLE" | head -1 | cut -f2) && echo "Stop position: $STOP_POS"
    ```

    This command finds the `DROP TABLE` event, steps back one line to the `Anonymous_Gtid` event that starts its transaction, and keeps that event's `Pos`. Stopping there, rather than at the `DROP` itself, ends the replay on a clean transaction boundary.

14. Restore the table from the backup:

    ```
    mysql demo -e "source /backups/course_notes.sql"
    ```

    `source` makes the `mysql` client read the backup file itself. Your own shell can't read `/backups`, but the client runs as `root` through `sudo`, so it can. The table dump doesn't name a database, so `demo` tells the client in which database to rebuild the table.

15. Check what the backup alone brought back:

    ```
    mysql -e "SELECT * FROM demo.course_notes;"
    ```

    The table is back with its three original rows, but rows 4 and 5 are missing. So far, this is the same outcome as the previous objective.

16. Replay the binary log from the backup up to the mistake:

    ```
    sudo mysqlbinlog --start-position=$START_POS --stop-position=$STOP_POS /var/lib/mysql/$BINLOG | mysql
    ```

    `mysqlbinlog` turns the binary log between the two positions back into statements, and `mysql` runs them against the server, re-applying every change made after the backup and stopping just before the `DROP`. The replay covers everything the server logged in that window, not just `course_notes`. In this lab, nothing else changed. On a busy server, check what's in the window before you replay it, and if the server rotated to a new binary log file in the meantime, replay each file in order.

17. Verify the point-in-time recovery:

    ```
    mysql -e "SELECT * FROM demo.course_notes;"
    ```

    WONDERFUL! All five rows are back: the three from the backup plus the two written after it, which the binary log replayed. The table is exactly as it was one moment before the `DROP`. That's point-in-time recovery.

18. Remove the demo database and the backup:

    ```
    mysql -e "DROP DATABASE demo;" && sudo rm -rf /backups
    ```

In this objective, you took a logical backup of a single table, lost the table to a mistake, and recovered it to the moment just before that mistake by restoring the backup and replaying the binary log. A backup gets you back to when the backup was taken. The binary log carries you the rest of the way.

