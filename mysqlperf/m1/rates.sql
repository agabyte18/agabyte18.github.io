-- Turn status counters into rates: read them twice, 5 seconds apart, and divide the difference.
-- Run:  mysql --login-path=dba -t < ~/labs/m1/rates.sql
-- (5 seconds keeps the run under long_query_time, 10 s, so it never counts as a slow query.)

-- The lab database holds the course's own objects. Does nothing if it already exists.
CREATE DATABASE IF NOT EXISTS lab;

-- First reading. A TEMPORARY table is visible only to this connection and disappears when it ends,
-- so nothing is left behind. performance_schema.global_status is SHOW GLOBAL STATUS as a table;
-- it stores every value as text, so CAST turns it into a number we can subtract.
--   Questions                         statements received
--   Select_scan                       full table scans
--   Slow_queries                      statements that ran longer than long_query_time
CREATE TEMPORARY TABLE lab.first_reading AS
  SELECT variable_name, CAST(variable_value AS UNSIGNED) AS value
  FROM performance_schema.global_status
  WHERE variable_name IN ('Questions', 'Select_scan', 'Slow_queries');

-- Wait 5 seconds. DO runs an expression and throws the result away, so nothing is printed.
DO SLEEP(5);

-- Second reading: join each saved value to the counter's current value, subtract, and divide by
-- the 5 seconds that passed. ROUND(..., 1) keeps one decimal place.
SELECT f.variable_name                                        AS counter,
       ROUND((CAST(s.variable_value AS UNSIGNED) - f.value) / 5, 1) AS per_second
FROM lab.first_reading AS f
JOIN performance_schema.global_status AS s USING (variable_name)
ORDER BY f.variable_name;
