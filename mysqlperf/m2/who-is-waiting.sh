mysql --login-path=dba -e "SELECT waiting_pid, wait_age_secs, waiting_query, blocking_pid, blocking_query FROM sys.innodb_lock_waits"
