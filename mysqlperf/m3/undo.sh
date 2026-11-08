#!/usr/bin/env bash
# Undo and redo exist only for your convenience: the lessons never need them. This undo reverses ONLY
# Module 3's effects.
# Undo Module 3 (Routine maintenance):
#   - stops workload.sh
#   - drops the three pile-up indexes (idx_hire_date, idx_last_name_old, idx_to_date)
#   - drops lab.old_log
#   - empties lab.activity_log (the rows the workload wrote)
#   - refreshes the statistics of the employees tables (ANALYZE TABLE)
#   - removes the maintenance line from your crontab (the Module 1 health check line stays) and
#     deletes ~/maintenance.log
# Reverses every Module 3 command: workload.sh (stopped), pile-up.sql (indexes dropped), old-log.sql
# (lab.old_log dropped), crontab.txt (maintenance line removed), maintenance.sh (nothing left to undo).
# table-size.sql only reads, so there is nothing to undo.
# Not touched: Modules 1 and 2 (idx_last_name from Module 2 stays).
# Usage: bash ~/labs/m3/undo.sh
set -uo pipefail

# Progress bar: shows how many of the steps are finished. Call:  progress <step> "<what it does>"
TOTAL=6
progress() {
  local finished=$(( $1 - 1 )) width=30 filled
  filled=$(( finished * width / TOTAL ))
  printf '\n[%s%s] %3d%%  Step %d of %d: %s\n' \
    "$(printf '%*s' "$filled" '' | tr ' ' '#')" "$(printf '%*s' $(( width - filled )) '' | tr ' ' '.')" \
    $(( finished * 100 / TOTAL )) "$1" "$TOTAL" "$2"
}
progress_done() {
  printf '\n[%s] 100%%  All %d steps finished\n' "$(printf '%*s' 30 '' | tr ' ' '#')" "$TOTAL"
}

# Stop every process of a script, including the mysql clients it started.
stop_script() {
  local pid pgid
  for pid in $(pgrep -f "$1"); do
    [ "$pid" = "$$" ] && continue
    # A script started from a terminal leads its own process group: kill the whole group (the minus sign)
    # so its mysql clients stop too; otherwise kill just that process.
    pgid=$(ps -o pgid= -p "$pid" | tr -d ' ')
    if [ "$pgid" = "$pid" ]; then kill -- "-$pgid" 2>/dev/null; else kill "$pid" 2>/dev/null; fi
  done
}
scalar() { mysql --login-path=dba -N -B -e "$1" 2> /dev/null; }
has_index() {
  [ "$(scalar "SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = 'employees' AND table_name = '$1' AND index_name = '$2'")" != "0" ]
}

progress 1 "Stopping the workload"
stop_script 'labs/m3/workload.sh'
sleep 1
echo "   done"

if ! mysql --login-path=dba -e 'SELECT 1' > /dev/null 2>&1; then
  echo "MySQL is not reachable with the dba login path, so the database steps are skipped."
  echo "Module 3 is only partly undone."
  exit 1
fi

progress 2 "Dropping the pile-up indexes"
for spec in employees:idx_hire_date employees:idx_last_name_old salaries:idx_to_date; do
  table=${spec%%:*}
  index=${spec##*:}
  if has_index "$table" "$index"; then
    mysql --login-path=dba -e "ALTER TABLE employees.${table} DROP INDEX ${index}" && echo "   dropped ${table}.${index}"
  else
    echo "   ${table}.${index} is not there"
  fi
done

progress 3 "Dropping lab.old_log"
if [ "$(scalar "SELECT COUNT(*) FROM information_schema.schemata WHERE schema_name = 'lab'")" = "1" ]; then
  mysql --login-path=dba -e "DROP TABLE IF EXISTS lab.old_log" && echo "   done"
else
  echo "   no lab database, nothing to do"
fi

progress 4 "Emptying lab.activity_log"
if [ "$(scalar "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'lab' AND table_name = 'activity_log'")" = "1" ]; then
  mysql --login-path=dba -e "TRUNCATE TABLE lab.activity_log" && echo "   done"
else
  echo "   no such table, nothing to do"
fi

progress 5 "Refreshing the statistics of the employees tables"
mysql --login-path=dba -e "ANALYZE TABLE employees.departments, employees.dept_emp, employees.dept_manager, employees.employees, employees.salaries, employees.titles" > /dev/null && echo "   done"

progress 6 "Removing the maintenance job from your crontab"
if current=$(crontab -l 2> /dev/null); then
  kept=$(printf '%s\n' "$current" | grep -v 'labs/m3/')
  if [ -z "${kept//[[:space:]]/}" ]; then crontab -r; else printf '%s\n' "$kept" | crontab -; fi
  echo "   done"
else
  echo "   no crontab, nothing to do"
fi
rm -f -- "$HOME/maintenance.log"

progress_done
echo "Module 3 is undone."
