mysql --login-path=dba -t -e "SELECT COUNT(*) AS redundant FROM sys.schema_redundant_indexes WHERE table_schema = 'employees'"
