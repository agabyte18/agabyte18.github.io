mysql --login-path=dba -t -e "SELECT table_name, redundant_index_name, dominant_index_name FROM sys.schema_redundant_indexes WHERE table_schema = 'employees'"
