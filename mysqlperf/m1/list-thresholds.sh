#!/usr/bin/env bash
# Lesson 1.5: list the health check thresholds.
# Usage: bash m1/list-thresholds.sh
mysql --login-path=dba -e "SELECT check_name, threshold FROM lab.health_thresholds"
