mysql --login-path=dba -e "SELECT DISTINCT blocking_pid, blocking_trx_age, blocking_trx_rows_modified, sql_kill_blocking_connection FROM sys.innodb_lock_waits"
