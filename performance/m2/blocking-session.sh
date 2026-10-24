mysql --login-path=dba -e "SELECT conn_id, command, time, trx_latency, last_statement FROM sys.session WHERE conn_id IN (SELECT blocking_pid FROM sys.innodb_lock_waits)"
