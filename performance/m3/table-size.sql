-- Three views of lab.old_log: real row count, size of its file on disk, and the row estimate
-- that information_schema shows (a cached estimate: it can be up to 24 hours old).
-- Run:  mysql --login-path=dba -t < ~/labs/m3/table-size.sql

-- 1. The real number of rows. Exact, but it has to read the whole table, which is slow on a big one.
SELECT COUNT(*) AS real_rows FROM lab.old_log;

-- 2. The size of the table's file on disk, in MB (1048576 bytes). This view is always current.
SELECT ROUND(file_size / 1048576) AS file_mb
FROM information_schema.innodb_tablespaces WHERE name = 'lab/old_log';

-- 3. The row count that information_schema reports. It is cached (information_schema_stats_expiry,
-- 24 hours by default) and refreshed by ANALYZE TABLE, so after big changes it can be far off.
SELECT table_rows AS estimated_rows
FROM information_schema.tables WHERE table_schema = 'lab' AND table_name = 'old_log';
