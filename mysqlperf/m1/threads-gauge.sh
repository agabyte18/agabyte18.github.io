mysql --login-path=dba -e "SHOW GLOBAL STATUS LIKE 'Threads_%'" && sleep 5 && mysql --login-path=dba -e "SHOW GLOBAL STATUS LIKE 'Threads_%'"
