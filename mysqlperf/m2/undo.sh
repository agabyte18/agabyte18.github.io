#!/usr/bin/env bash
# Undo and redo exist only for your convenience: the lessons never need them. This undo reverses ONLY
# Module 2's effects.
# Undo Module 2 (Diagnosing incidents):
#   - stops workload.sh, blocker.sh and search-page.sh
#   - drops the idx_last_name index from employees.employees
#   - empties lab.activity_log (the rows the workload wrote)
#   - clears the Performance Schema statement history
#   - takes the oldest_trx_s and full_scan_statements checks out of lab.health_check,
#     going back to Module 1's three-check version (only if that procedure exists)
# Reverses every Module 2 command: workload.sh, blocker.sh and search-page.sh (stopped),
# health-check-2.sql and health-check-3.sql (replaced by health-check-1.sql), the idx_last_name index,
# and the rows and statement history those scripts left. rates.sql, surname-stats.sql and
# the cron alerts only read, so there is nothing to undo.
# Not touched: Module 1 (webhook, lab.health_thresholds, employees).
# Usage: bash ~/labs/m2/undo.sh
set -uo pipefail

# Progress bar: shows how many of the steps are finished. Call:  progress <step> "<what it does>"
TOTAL=5
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

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

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

progress 1 "Stopping the workload, the blocker and the search page"
stop_script 'labs/m2/workload.sh'
stop_script 'labs/m2/blocker.sh'
stop_script 'labs/m2/search-page.sh'
sleep 1
echo "   done"

if ! mysql --login-path=dba -e 'SELECT 1' > /dev/null 2>&1; then
  echo "MySQL is not reachable with the dba login path, so the database steps are skipped."
  echo "Module 2 is only partly undone."
  exit 1
fi

progress 2 "Dropping idx_last_name"
if [ "$(scalar "SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = 'employees' AND table_name = 'employees' AND index_name = 'idx_last_name'")" != "0" ]; then
  mysql --login-path=dba -e "ALTER TABLE employees.employees DROP INDEX idx_last_name" && echo "   done"
else
  echo "   not there, nothing to do"
fi

progress 3 "Emptying lab.activity_log and the statement history"
if [ "$(scalar "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'lab' AND table_name = 'activity_log'")" = "1" ]; then
  mysql --login-path=dba -e "TRUNCATE TABLE lab.activity_log" && echo "   activity_log emptied"
else
  echo "   no activity_log table, nothing to do"
fi
mysql --login-path=dba -e "CALL sys.ps_truncate_all_tables(FALSE)" && echo "   statement history cleared"

progress 4 "Going back to the three-check health check"
if [ "$(scalar "SELECT COUNT(*) FROM information_schema.routines WHERE routine_schema = 'lab' AND routine_name = 'health_check'")" = "1" ]; then
  mysql --login-path=dba -e "DELETE FROM lab.health_thresholds WHERE check_name IN ('oldest_trx_s', 'full_scan_statements')"
  mysql --login-path=dba < "$HERE/health-check-1.sql" && echo "   done"
else
  echo "   Module 1's health check is not installed, nothing to restore"
fi

progress 5 "Putting the full_scans_per_s threshold back to 100"
mysql --login-path=dba -e "UPDATE lab.health_thresholds SET threshold = 100 WHERE check_name = 'full_scans_per_s'" 2> /dev/null \
  && echo "   done" || echo "   skipped (threshold table not installed)"

progress_done
echo "Module 2 is undone."
