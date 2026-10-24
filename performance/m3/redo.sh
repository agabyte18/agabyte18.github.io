#!/usr/bin/env bash
# Redo Module 3 (Routine maintenance): run every Module 3 script and changing command once, in lesson order.
# Redo and undo exist only for your convenience: the lessons never need them. Each redo repeats ONLY its
# own module's scripts and commands, and needs the earlier modules' setup to be in place already.
# Needs Modules 1 and 2 done first. The workload runs in the background.
#   Lesson 3.1  workload.sh, pile-up.sql, make the three indexes invisible, make idx_hire_date visible
#               again, then drop the three indexes
#   Lesson 3.2  old-log.sql, table-size.sql after each change (delete, ANALYZE TABLE, OPTIMIZE TABLE),
#               then drop lab.old_log
#   Lesson 3.3  maintenance.sh once by hand, then the schedule from crontab.txt (REPLACES your crontab:
#               the health check from Module 1 plus maintenance.sh every 2 minutes), and one cron run
# Not redone: reading commands (they change nothing) and the 2-minute wait for the usage statistics.
# Safe to run again (leftover pile-up indexes are dropped first). It takes a few minutes.
# Usage: bash ~/labs/m3/redo.sh        Run it as your normal user.
set -uo pipefail

# Progress bar: shows how many of the steps are finished. Call:  progress <step> "<what it does>"
TOTAL=4
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
fail() { echo "   FAILED: $*"; echo "Module 3 is NOT fully redone."; exit 1; }
sql() { mysql --login-path=dba "$@"; }   # short for the mysql client with the course login

# Drop pile-up indexes left by an interrupted run, so pile-up.sql can add them again.
progress 1 "Making sure no pile-up indexes are left over"
for spec in employees:idx_hire_date employees:idx_last_name_old salaries:idx_to_date; do
  table=${spec%%:*}                                         # the part before the colon
  index=${spec##*:}                                         # the part after it
  if [ "$(sql -N -B -e "SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = 'employees' AND table_name = '$table' AND index_name = '$index'")" != "0" ]; then
    sql -e "ALTER TABLE employees.$table DROP INDEX $index" || fail "drop $index"
    echo "   dropped leftover $table.$index"
  fi
done

# --- Lesson 3.1: unused and redundant indexes ----------------------------------------------------
progress 2 "Lesson 3.1: pile-up.sql, invisible indexes, dropping them"
bash "$HERE/workload.sh" 4 240 > /dev/null &                # the workload that makes usage statistics
workload=$!
sql < "$HERE/pile-up.sql" || fail "pile-up.sql"             # three indexes nothing should need
# Check: make them invisible (the optimizer ignores them, nothing is deleted) ...
sql -e "ALTER TABLE employees.employees ALTER INDEX idx_hire_date INVISIBLE, ALTER INDEX idx_last_name_old INVISIBLE" || fail "invisible"
sql -e "ALTER TABLE employees.salaries ALTER INDEX idx_to_date INVISIBLE" || fail "invisible"
# ... and bring idx_hire_date back, as the lesson does to show the plan changes.
sql -e "ALTER TABLE employees.employees ALTER INDEX idx_hire_date VISIBLE" || fail "visible"
# Change: drop them for good.
sql -e "ALTER TABLE employees.employees DROP INDEX idx_hire_date, DROP INDEX idx_last_name_old" || fail "drop"
sql -e "ALTER TABLE employees.salaries DROP INDEX idx_to_date" || fail "drop"

# --- Lesson 3.2: statistics and rebuilds ---------------------------------------------------------
progress 3 "Lesson 3.2: old-log.sql, table-size.sql, DELETE, ANALYZE, OPTIMIZE"
sql < "$HERE/old-log.sql" || fail "old-log.sql"             # lab.old_log with 2.8 million rows
sql -t < "$HERE/table-size.sql" || fail "table-size.sql"    # sizes after the build
sql -e "DELETE FROM lab.old_log WHERE id <= 2500000" || fail "DELETE"
sql -t < "$HERE/table-size.sql" || fail "table-size.sql"    # the file does not shrink, the estimate is stale
sql -e "ANALYZE TABLE lab.old_log" > /dev/null || fail "ANALYZE TABLE"   # refreshes the estimate
sql -t < "$HERE/table-size.sql" || fail "table-size.sql"
sql -e "OPTIMIZE TABLE lab.old_log" > /dev/null || fail "OPTIMIZE TABLE"  # rebuilds the file smaller
sql -t < "$HERE/table-size.sql" || fail "table-size.sql"
sql -e "DROP TABLE lab.old_log" || fail "DROP TABLE"        # clean up, as the lesson does
wait "$workload" 2> /dev/null                               # let the workload finish

# --- Lesson 3.3: the maintenance schedule ----------------------------------------------------------
progress 4 "Lesson 3.3: maintenance.sh, then cron"
bash "$HERE/maintenance.sh" > /dev/null || fail "maintenance.sh"
crontab "$HERE/crontab.txt" || fail "crontab.txt"
crontab -l | grep -v '^#'
echo "   waiting for cron's next maintenance run (up to 2 minutes)"
for _ in $(seq 130); do
  grep -qs ANALYZE "$HOME/maintenance.log" && break
  sleep 1
done
grep -qs ANALYZE "$HOME/maintenance.log" || fail "cron has not run maintenance.sh"

progress_done
echo "Module 3 is redone."
