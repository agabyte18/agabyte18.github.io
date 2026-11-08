mysql --login-path=dba -e "SELECT conn_id, user, db, command, time, current_statement FROM sys.session"
