mysql --login-path=dba -e "SELECT query, full_scan, exec_count, avg_latency, rows_sent_avg, rows_examined_avg FROM sys.statement_analysis WHERE db = 'employees' LIMIT 3"
