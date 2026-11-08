mysql --login-path=dba -e "SELECT query, exec_count, total_latency, rows_examined_avg FROM sys.statements_with_full_table_scans WHERE db = 'employees'"
