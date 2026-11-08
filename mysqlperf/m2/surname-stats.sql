-- How the surname search is doing: runs, average time and 95th-percentile time since the statement history was cleared.
-- Run:  mysql --login-path=dba -t < ~/labs/m2/surname-stats.sql

-- events_statements_summary_by_digest keeps one row per kind of statement: statements that differ
-- only in their literal values (last_name = 'Smith' / 'Jones') share a row, written with ? in place
-- of the values. Times are in picoseconds, so dividing by 1e9 gives milliseconds.
--   count_star      how many times the statement ran
--   avg_timer_wait  average run time
--   quantile_95     95th percentile (p95): 95 % of the runs finished within this time
SELECT count_star                   AS runs,
       ROUND(avg_timer_wait / 1e9, 1) AS avg_ms,
       ROUND(quantile_95   / 1e9, 1) AS p95_ms
FROM performance_schema.events_statements_summary_by_digest
-- Only the employees schema, and only the statement text that looks like the surname search.
WHERE schema_name = 'employees' AND digest_text LIKE '%`last_name` = ?%';
