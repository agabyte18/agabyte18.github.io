#!/usr/bin/env bash
# Redo Module 2 (Diagnosing incidents): run every Module 2 script and changing command once, in lesson order.
# Redo and undo exist only for your convenience: the lessons never need them. Each redo repeats ONLY its
# own module's scripts and commands, and needs the earlier modules' setup to be in place already.
# Needs Module 1 done first (its server, health check, Slack webhook and cron schedule: cron sends the alerts). The lessons run the long ones in separate terminals; here they run in
# the background for a short time and the script waits for them.
#   Lesson 2.1  workload.sh, blocker.sh, rates.sql, the alerts from cron (it waits for them),
#               health-check-2.sql, then blocker.sh again
#   Lesson 2.2  search-page.sh, then waits for cron's alert
#   Lesson 2.3  surname-stats.sql and rates.sql before and after ALTER TABLE ... ADD INDEX idx_last_name,
#               health-check-3.sql, the alerts from cron, and the statement-history clean-ups
# Not redone: reading commands (they change nothing) and KILL of the blocking session (blocker.sh
# ends by itself and rolls back).
# Safe to run again. It takes about 11 minutes.
# Usage: bash ~/labs/m2/redo.sh        Run it as your normal user.
set -uo pipefail

# Progress bar: shows how many of the steps are finished. Call:  progress <step> "<what it does>"
TOTAL=3
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
fail() { echo "   FAILED: $*"; echo "Module 2 is NOT fully redone."; exit 1; }
sql() { mysql --login-path=dba "$@"; }   # short for the mysql client with the course login

# --- Lesson 2.1: the blocking incident -----------------------------------------------------------
# The alerts are sent by the cron schedule from Module 1 (Lesson 1.7), so this script only waits for them.
progress 1 "Lesson 2.1: blocking (workload, blocker, alerts, rates)"
bash "$HERE/workload.sh" 4 640 > /dev/null &
workload=$!
sleep 10                                                    # let the workload write some rows
bash "$HERE/blocker.sh" 90 > /dev/null &                    # a transaction that never commits: idle 90 s, then the DELETE
blocker=$!
sleep 170                                                   # the DELETE runs at 90 s; the wait needs 10 s, then one cron run alerts
sql -t < "$HERE/rates.sql" || fail "rates.sql"              # the workload's rates while blocked
wait "$blocker"                                             # blocker.sh ends and rolls back (the fix)
sql < "$HERE/health-check-2.sql" || fail "health-check-2.sql"   # prevent: add the oldest_trx_s check
bash "$HERE/blocker.sh" 90 > /dev/null &                    # the incident again: the new check sees it first (oldest_trx_s alone,
blocker=$!                                                  # then oldest_lock_wait_s too once the DELETE has run)
sleep 170
wait "$blocker"

# --- Lesson 2.2: the missing-index incident ------------------------------------------------------
progress 2 "Lesson 2.2: missing index (search page, alert)"
bash "$HERE/search-page.sh" 30 260 > /dev/null &             # many visitors search by surname
search=$!
sleep 75                                                    # identify: cron's next run reports threads_running over its limit

# --- Lesson 2.3: fix, verify, prevent -------------------------------------------------------------
progress 3 "Lesson 2.3: idx_last_name, before/after numbers, five-check health check"
sql -e "CALL sys.ps_truncate_all_tables(FALSE)"             # measure from a clean statement history
sleep 15                                                    # warm-up before the "before" reading
sql -t < "$HERE/surname-stats.sql" || fail "surname-stats.sql"
sql -t < "$HERE/rates.sql" || fail "rates.sql"
# Remediate: the index (skipped if a previous run already added it).
if [ "$(sql -N -B -e "SELECT COUNT(*) FROM information_schema.statistics WHERE table_schema = 'employees' AND table_name = 'employees' AND index_name = 'idx_last_name'")" = "0" ]; then
  sql -e "ALTER TABLE employees.employees ADD INDEX idx_last_name (last_name)" || fail "ADD INDEX idx_last_name"
fi
sql -e "CALL sys.ps_truncate_all_tables(FALSE)"             # the "after" measurement starts clean
sleep 15
sql -t < "$HERE/surname-stats.sql" || fail "surname-stats.sql"
sql -t < "$HERE/rates.sql" || fail "rates.sql"
sleep 65                                                    # verify: cron's next run finds no more scan alert
tail -2 "$HOME/health-alert.log"
# Prevent: add the full_scan_statements check, then provoke it with an unindexed query.
sql < "$HERE/health-check-3.sql" || fail "health-check-3.sql"
sql employees -e "SELECT COUNT(*) FROM employees WHERE hire_date = '1990-01-01'" > /dev/null
sleep 65                                                    # cron's next run alerts on full_scan_statements
wait "$search" "$workload" 2> /dev/null                     # let the background scripts finish
sql -e "CALL sys.ps_truncate_all_tables(FALSE)"             # the history is cumulative: clear it last

progress_done
echo "Module 2 is redone."
