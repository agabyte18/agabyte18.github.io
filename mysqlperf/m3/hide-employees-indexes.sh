mysql --login-path=dba -t -e "ALTER TABLE employees.employees ALTER INDEX idx_hire_date INVISIBLE, ALTER INDEX idx_last_name_old INVISIBLE"
