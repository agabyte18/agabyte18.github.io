#!/usr/bin/env bash
# The safe, cheap maintenance steps. It changes nothing a human should decide:
# it refreshes statistics, and it only lists index candidates (nothing is dropped).
# Usage: bash ~/labs/m3/maintenance.sh        (Lesson 3.3 runs it from cron: see crontab.txt)

# Stop at the first error (-e), on an unset variable (-u), or when any command in a pipe fails
# (pipefail), so a failure shows up in the log.
set -euo pipefail

# 1. ANALYZE TABLE refreshes the statistics the optimizer uses to choose a plan. It is cheap and
#    safe to repeat. -t prints a table even though the output goes to the log.
echo "== ANALYZE TABLE on the employees tables =="
mysql --login-path=dba -t -e "ANALYZE TABLE employees.departments, employees.dept_emp, employees.dept_manager, employees.employees, employees.salaries, employees.titles"

# 2. Indexes with no reads since the server started. These are only candidates: a person decides.
#    The filter keeps out the performance_schema rows that also show up in this view.
echo "== Unused index candidates =="
mysql --login-path=dba -t -e "SELECT * FROM sys.schema_unused_indexes WHERE object_schema = 'employees'"

# 3. Indexes whose columns are already covered by a longer index (the dominant one).
echo "== Redundant index candidates =="
mysql --login-path=dba -t -e "SELECT table_name, redundant_index_name, dominant_index_name FROM sys.schema_redundant_indexes WHERE table_schema = 'employees'"
