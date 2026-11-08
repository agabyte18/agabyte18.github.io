mysql --login-path=dba -e "UPDATE lab.health_thresholds SET threshold = 1 WHERE check_name = 'full_scans_per_s'"
