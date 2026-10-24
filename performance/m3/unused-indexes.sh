mysql --login-path=dba -t -e "SELECT * FROM sys.schema_unused_indexes where object_schema = 'employees'"
