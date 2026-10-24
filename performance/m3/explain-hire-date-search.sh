mysql --login-path=dba -t -e "EXPLAIN SELECT COUNT(*) FROM employees.employees WHERE hire_date = '1990-01-01'"
