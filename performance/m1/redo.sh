#!/usr/bin/env bash
# Redo Module 1 (Catching issues early): repeat every Module 1 script and command, without any typing.
# Redo and undo exist only for your convenience: the lessons never need them. Each redo repeats ONLY its
# own module's scripts and commands.
#   1. installs MySQL Server 8.4 from Oracle's repository (install-mysql-8.4.sh)
#   2. waits until the server answers
#   3. creates the dba user (create-dba-user.sql) and sets its password to the course value
#      (this also cures ERROR 1045 "Access denied for user 'dba'" caused by an old account)
#   4. saves the dba login path, answering the silent password prompt for you; if the check
#      still gives ERROR 1045, it resets both passwords and retries once
#   5. loads and checks the employees sample data (load-employees.sh)
#   6. installs the health check, lab.health_check and its thresholds (health-check.sql)
#   7. saves the Slack webhook URL to ~/.config/mysql-alerts/webhook, if labs/.webhook (one line, the
#      URL; never put it in git) exists or the webhook file is already there
#   8. runs every other Module 1 script once: workload.sh (40 s, in the background), rates.sql, and
#      health-alert.sh with full_scans_per_s lowered to 1 (it posts to Slack), then back to 100
#   9. installs the schedule from crontab.txt (Lesson 1.7): cron runs health-alert.sh every minute
#      and appends to ~/health-alert.log. This REPLACES your crontab.
# Not redone: reading commands (they change nothing) and creating the Slack channel itself
# (Lesson 1.6, Step 1).
# Steps that are already done are skipped, so it is safe to run again.
# Usage: bash ~/labs/m1/redo.sh        Run it as your normal user. It calls sudo where it needs root.
set -uo pipefail

# Progress bar: shows how many of the steps are finished. Call:  progress <step> "<what it does>"
TOTAL=9
progress() {
  local done=$(( $1 - 1 )) width=30 filled
  filled=$(( done * width / TOTAL ))
  printf '\n[%s%s] %3d%%  Step %d of %d: %s\n' \
    "$(printf '%*s' "$filled" '' | tr ' ' '#')" "$(printf '%*s' $(( width - filled )) '' | tr ' ' '.')" \
    $(( done * 100 / TOTAL )) "$1" "$TOTAL" "$2"
}
progress_done() {
  printf '\n[%s] 100%%  All %d steps finished\n' "$(printf '%*s' 30 '' | tr ' ' '#')" "$TOTAL"
}

HERE=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PASSWORD='Course#Pass84'

if [ "$(id -u)" = "0" ]; then
  echo "Run this as your normal user, not root: the login path and ~/test_db belong to your user."
  exit 1
fi

fail() { echo "   FAILED: $*"; echo "Module 1 is NOT fully redone."; exit 1; }
sql() { mysql --login-path=dba "$@"; }   # short for the mysql client with the course login

progress 1 "Installing MySQL Server 8.4"
if dpkg -s mysql-community-server > /dev/null 2>&1 && mysql --version 2> /dev/null | grep -q 'Ver 8\.4'; then
  echo "   MySQL 8.4 is already installed"
else
  sudo bash "$HERE/install-mysql-8.4.sh" || fail "the install script reported an error"
fi

progress 2 "Waiting for the server"
sudo systemctl start mysql 2> /dev/null || true
for _ in $(seq 60); do
  sudo mysql -e 'SELECT 1' > /dev/null 2>&1 && break
  sleep 1
done
sudo mysql -e 'SELECT 1' > /dev/null 2>&1 || fail "the server does not answer to 'sudo mysql'"
echo "   server is up"

progress 3 "Creating the dba user"
sudo mysql < "$HERE/create-dba-user.sql" || fail "create-dba-user.sql"
# CREATE USER IF NOT EXISTS keeps an old account's password, so set it again to be sure.
sudo mysql -e "ALTER USER 'dba'@'localhost' IDENTIFIED BY '${PASSWORD}'" || fail "could not set the dba password"
echo "   done"

progress 4 "Saving the dba login path"
# mysql_config_editor reads the password from a terminal, so 'script' provides one.
# $1 = seconds to wait for the prompt before typing the password.
save_login_path() {
  mysql_config_editor remove --login-path=dba 2> /dev/null
  ( sleep "$1"; printf '%s\n' "$PASSWORD"; sleep 1 ) \
    | script -qc "mysql_config_editor set --login-path=dba --user=dba --password" /dev/null > /dev/null
}
check_login() {
  login_out=$(mysql --login-path=dba -t -e "SELECT CURRENT_USER() AS logged_in_as, @@version AS version" 2>&1)
}

save_login_path 1
if ! check_login; then
  if [[ "$login_out" == *"ERROR 1045"* ]]; then
    # 1045 = the saved password and the account's password disagree. Reset both sides and try once more.
    echo "   ERROR 1045: the saved password does not match the dba account. Resetting both and retrying."
    sudo mysql -e "ALTER USER 'dba'@'localhost' IDENTIFIED BY '${PASSWORD}'" || fail "could not set the dba password"
    save_login_path 3
    check_login || fail "still $login_out"
  else
    fail "$login_out"
  fi
fi
echo "$login_out"

progress 5 "Loading the employees sample data"
rows=$(mysql --login-path=dba -N -B -e "SELECT COUNT(*) FROM employees.salaries" 2> /dev/null)
if [ "${rows:-0}" = "2844047" ]; then
  echo "   employees is already loaded (2,844,047 salary rows)"
else
  echo "   this takes 1-3 minutes"
  bash "$HERE/load-employees.sh" || fail "load-employees.sh"
fi

progress 6 "Installing the health check"
# Safe to repeat: the script keeps thresholds you have already tuned.
mysql --login-path=dba < "$HERE/health-check.sql" || fail "health-check.sql"
echo "   lab.health_check installed"

progress 7 "Saving the Slack webhook URL"
WEBHOOK_DIR="$HOME/.config/mysql-alerts"
mkdir -p -m 700 "$WEBHOOK_DIR"
if [ -s "$HERE/../.webhook" ]; then
  cp "$HERE/../.webhook" "$WEBHOOK_DIR/webhook"
  chmod 600 "$WEBHOOK_DIR/webhook"
  echo "   webhook saved from labs/.webhook"
elif [ -s "$WEBHOOK_DIR/webhook" ]; then
  echo "   webhook already saved"
else
  echo "   no webhook URL: save yours as in Lesson 1.6, Step 2 (vim ~/.config/mysql-alerts/webhook)"
fi

progress 8 "Replaying Lessons 1.3 to 1.6: workload, rates, threshold test, Slack alert"
# The lessons run these in two terminals. Here the workload runs in the background for 40 seconds
# and everything else runs while it is busy; wait collects it at the end.
bash "$HERE/workload.sh" 4 40 > /dev/null &
workload=$!
sleep 10                                                  # let the workload warm up
sql -e "CALL sys.ps_truncate_all_tables(FALSE)"           # Lesson 1.4: start the statement history clean
sql -t < "$HERE/rates.sql" || fail "rates.sql"            # Lesson 1.3: per-second rates (takes 5 s)
# Lessons 1.5 and 1.6: lower the scan threshold to 1 so the busy workload trips the check, send the
# alert to Slack, then put the threshold back to 100.
sql -e "UPDATE lab.health_thresholds SET threshold = 1 WHERE check_name = 'full_scans_per_s'" || fail "threshold update"
bash "$HERE/health-alert.sh" || fail "health-alert.sh"
sql -e "UPDATE lab.health_thresholds SET threshold = 100 WHERE check_name = 'full_scans_per_s'" || fail "threshold update"
wait "$workload"

progress 9 "Lesson 1.7: scheduling the health check with cron"
crontab "$HERE/crontab.txt" || fail "crontab.txt"
crontab -l | grep -v '^#'

progress_done
echo "Module 1 is redone. Create the #mysql-alerts channel in Slack yourself if you have not (Lesson 1.6, Step 1)."
