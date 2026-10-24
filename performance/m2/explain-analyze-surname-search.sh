mysql --login-path=dba -e "EXPLAIN ANALYZE SELECT COUNT(*) FROM employees.employees WHERE last_name = 'Facello'\G"
