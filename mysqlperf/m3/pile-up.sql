-- Simulates years of "just add an index": three extra indexes on employees.
-- Run:  mysql --login-path=dba < ~/labs/m3/pile-up.sql

-- Two indexes on employees.employees, added in one ALTER so the table is rebuilt only once.
--   idx_hire_date      nothing in the workload searches by hire date, so it will go unused.
--   idx_last_name_old  a second index on last_name, a duplicate of Module 2's idx_last_name.
ALTER TABLE employees.employees
  ADD INDEX idx_hire_date (hire_date),
  ADD INDEX idx_last_name_old (last_name);

-- idx_to_date: another index nothing uses. It is the big one (about 49 MB), because salaries
-- has 2.8 million rows.
ALTER TABLE employees.salaries
  ADD INDEX idx_to_date (to_date);
