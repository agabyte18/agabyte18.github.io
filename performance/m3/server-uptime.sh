mysql --login-path=dba -t -e "SELECT variable_value AS uptime_seconds FROM performance_schema.global_status WHERE variable_name = 'Uptime'"
