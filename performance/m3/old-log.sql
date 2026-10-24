-- Builds lab.old_log: a big log table (about 2.8 million rows) to practise clean-up on.
-- Run:  mysql --login-path=dba < ~/labs/m3/old-log.sql      (takes about 30 seconds)

-- Start from scratch, so the script can be run again.
DROP TABLE IF EXISTS lab.old_log;

-- id counts up as rows are added, so the lowest ids are the "oldest" rows.
-- logged_at fills itself with the time of the insert.
CREATE TABLE lab.old_log (
  id        BIGINT AUTO_INCREMENT PRIMARY KEY,
  emp_no    INT NOT NULL,
  logged_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- One log row for each row in employees.salaries. Only emp_no is given; id and logged_at fill in.
INSERT INTO lab.old_log (emp_no) SELECT emp_no FROM employees.salaries;
