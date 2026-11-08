mysql --login-path=dba -e "UPDATE lab.health_thresholds SET threshold = 0 WHERE check_name = 'full_scans_per_s'"
