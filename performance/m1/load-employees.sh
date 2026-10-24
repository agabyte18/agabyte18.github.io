#!/usr/bin/env bash
# Download and load the "employees" sample database (about 4 million rows in total).
# Usage: bash load-employees.sh    (uses the "dba" login path created in Module 1)
set -euo pipefail

# Work in the home folder. Clone only the latest version (--depth 1) and only if not downloaded yet.
cd "${HOME}"
if [ ! -d test_db ]; then
  git clone --depth 1 https://github.com/datacharmer/test_db.git
fi
cd test_db
# Create and fill the employees database (takes about 2 minutes).
mysql --login-path=dba < employees.sql
# Check the load: the test script compares checksums of every table with the published ones (OK or FAIL).
mysql --login-path=dba -t < test_employees_sha.sql
