mysql --login-path=dba -e "SELECT query, exec_count, total_latency, avg_latency FROM sys.statement_analysis WHERE db = 'employees' LIMIT 5"
