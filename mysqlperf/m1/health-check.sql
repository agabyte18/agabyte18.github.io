-- The course health check: three checks, with their thresholds in a table.
-- Install:  mysql --login-path=dba < ~/labs/m1/health-check.sql
-- Run:      mysql --login-path=dba -t -e "CALL lab.health_check('table')"
--           Returns one row per check at or over its threshold, and nothing when all is well.
--           'slack' returns the same result as one Slack message (JSON), or nothing.
-- It takes 5 seconds: the rate check reads its counter twice, 5 seconds apart.

CREATE DATABASE IF NOT EXISTS lab;

CREATE TABLE IF NOT EXISTS lab.health_thresholds (
  check_name VARCHAR(64)    NOT NULL PRIMARY KEY,
  threshold  DECIMAL(12,1)  NOT NULL,
  meaning    VARCHAR(200)   NOT NULL
);

-- INSERT IGNORE keeps any threshold you have already tuned when you reinstall.
INSERT IGNORE INTO lab.health_thresholds VALUES
  ('oldest_lock_wait_s', 10, 'seconds the longest-waiting InnoDB row-lock wait has waited'),
  ('threads_running',    20, 'statements executing right now (Threads_running)'),
  ('full_scans_per_s',  100, 'full table scans per second (Select_scan)');

DROP PROCEDURE IF EXISTS lab.health_check;

-- The procedure body contains ';', which would end the statement early in the mysql client,
-- so the statement delimiter is changed to // here and restored at the end.
DELIMITER //

CREATE PROCEDURE lab.health_check(IN p_format VARCHAR(5))
BEGIN
  -- Remove leftovers from an interrupted run, so the procedure is safe to run again.
  DROP TEMPORARY TABLE IF EXISTS lab.health_values, lab.first_reading;
  CREATE TEMPORARY TABLE lab.health_values (
    check_name VARCHAR(64)   NOT NULL PRIMARY KEY,
    value      DECIMAL(12,1) NOT NULL
  );

  -- Gauges: one reading is enough.
  INSERT INTO lab.health_values
    SELECT 'threads_running', CAST(variable_value AS UNSIGNED)
    FROM performance_schema.global_status WHERE variable_name = 'Threads_running';
  -- sys.innodb_lock_waits has no rows when nothing is blocked, so MAX() is NULL; COALESCE makes it 0.
  INSERT INTO lab.health_values
    SELECT 'oldest_lock_wait_s', COALESCE(MAX(wait_age_secs), 0) FROM sys.innodb_lock_waits;

  -- Counter: two readings, 5 seconds apart, give a rate per second.
  CREATE TEMPORARY TABLE lab.first_reading AS
    SELECT variable_name, CAST(variable_value AS UNSIGNED) AS value
    FROM performance_schema.global_status
    WHERE variable_name = 'Select_scan';
  DO SLEEP(5);
  -- The divisor 5 must match the SLEEP(5) above.
  INSERT INTO lab.health_values
    SELECT 'full_scans_per_s',
           (CAST(s.variable_value AS UNSIGNED) - f.value) / 5
    FROM lab.first_reading AS f
    JOIN performance_schema.global_status AS s USING (variable_name);

  -- Report only the checks at or over their threshold.
  IF p_format = 'slack' THEN
    SELECT JSON_OBJECT('text', CONCAT(
             ':rotating_light: MySQL health check on ', @@hostname, ': ',
             COUNT(*), ' check(s) over threshold\n',
             GROUP_CONCAT(CONCAT('- ', v.check_name, ' = ', v.value, ' (threshold ', t.threshold, ')')
                          ORDER BY v.check_name SEPARATOR '\n'))) AS slack_message
    FROM lab.health_values AS v
    JOIN lab.health_thresholds AS t USING (check_name)
    WHERE v.value >= t.threshold
    -- Return no row at all when nothing is over threshold; health-alert.sh stays silent on empty output.
    HAVING COUNT(*) > 0;
  ELSE
    SELECT v.check_name, v.value, t.threshold, t.meaning
    FROM lab.health_values AS v
    JOIN lab.health_thresholds AS t USING (check_name)
    WHERE v.value >= t.threshold
    ORDER BY v.check_name;
  END IF;

  DROP TEMPORARY TABLE lab.health_values, lab.first_reading;
END //

DELIMITER ;
