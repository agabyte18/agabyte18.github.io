#!/usr/bin/env bash
# Undo and redo exist only for your convenience: the lessons never need them. This undo reverses ONLY
# Module 1's effects.
# Undo Module 1 (Catching issues early): remove MySQL and everything the module set up.
#   - the workload, if it is still running, the cron lines of Modules 1 and 3 with their logs
#     (~/health-alert.log, ~/maintenance.log), and the Slack webhook file in ~/.config/mysql-alerts
#     (the lab database, health check and thresholds go with the MySQL data below)
#   - the dba login path (~/.mylogin.cnf entry) and ~/.mysql_history. A stale entry would give
#     ERROR 1045 after a reinstall, because the new dba account is created from scratch.
#   - the employees test data (~/test_db)
#   - MySQL Server 8.4, its client tools and Oracle's APT repository
#   - ALL MySQL data: /var/lib/mysql, /etc/mysql, the logs. Every database is lost.
# Reverses every Module 1 command: install-mysql-8.4.sh, create-dba-user.sql, load-employees.sh,
# health-check.sql (the lab database goes with the MySQL data), workload.sh (stopped), crontab.txt
# (cron lines and logs removed), health-alert.sh
# and the webhook (file deleted). rates.sql only reads, so there is nothing to undo.
# Not removed: git, curl, wget, gnupg, lsb-release. Other software may use them,
# and this script cannot tell whether they were installed before the course.
# Not touched: the course files in ~/labs.
# Usage: bash ~/labs/m1/undo.sh        (asks before it deletes anything; add -y to skip the question)
#        Run it as your normal user. It calls sudo where it needs root.
set -uo pipefail

# Progress bar: shows how many of the steps are finished. Call:  progress <step> "<what it does>"
TOTAL=7
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

if [ "$(id -u)" = "0" ]; then
  echo "Run this as your normal user, not root: the login path and ~/test_db belong to your user."
  exit 1
fi

if [ "${1:-}" != "-y" ]; then
  echo "This will REMOVE MySQL Server and DELETE ALL its databases (not just the course ones)."
  read -r -p "Type 'yes' to go on: " answer
  [ "$answer" = "yes" ] || { echo "Cancelled, nothing was changed."; exit 1; }
fi

progress 1 "Stopping the workload, removing the cron lines and deleting the Slack webhook"
# Lessons 1.7 and 3.3 put jobs in your crontab. Keep any lines that are not ours.
if current=$(crontab -l 2> /dev/null); then
  kept=$(printf '%s\n' "$current" | grep -v 'labs/m[13]/')
  # Our comment lines (from crontab.txt) stay behind once the job lines are gone: if only comments and
  # blank lines are left, the crontab does nothing, so remove it completely.
  if ! printf '%s\n' "$kept" | grep -qv '^[[:space:]]*\(#\|$\)'; then crontab -r; else printf '%s\n' "$kept" | crontab -; fi
fi
rm -f -- "$HOME/health-alert.log" "$HOME/maintenance.log"
for pid in $(pgrep -f 'labs/m1/workload.sh'); do
  [ "$pid" = "$$" ] && continue
  # A script started from a terminal leads its own process group: kill the whole group (the minus sign)
  # so its mysql clients stop too; otherwise kill just that process.
  pgid=$(ps -o pgid= -p "$pid" | tr -d ' ')
  if [ "$pgid" = "$pid" ]; then kill -- "-$pgid" 2>/dev/null; else kill "$pid" 2>/dev/null; fi
done
rm -f -- "$HOME/.config/mysql-alerts/webhook"
rmdir "$HOME/.config/mysql-alerts" 2> /dev/null
echo "   done"

progress 2 "Removing the dba login path and the client history"
if command -v mysql_config_editor > /dev/null 2>&1; then
  if [ -n "$(mysql_config_editor print --login-path=dba 2> /dev/null)" ]; then
    mysql_config_editor remove --login-path=dba && echo "   dba login path removed"
  else
    echo "   no dba login path"
  fi
  # Removing the last entry leaves an empty ~/.mylogin.cnf behind: delete it, but keep other people's entries.
  if [ -z "$(mysql_config_editor print --all 2> /dev/null)" ]; then
    rm -f -- "$HOME/.mylogin.cnf"
  fi
elif [ -e "$HOME/.mylogin.cnf" ]; then
  echo "   mysql_config_editor is not installed, so ~/.mylogin.cnf was left alone."
  echo "   Delete the file by hand if it holds only the dba login path. A leftover dba entry"
  echo "   gives ERROR 1045 (access denied) once MySQL is installed again, because the new"
  echo "   dba account has a different password than the one saved in it."
fi
rm -f -- "$HOME/.mysql_history"

progress 3 "Deleting the employees test data (~/test_db)"
rm -rf -- "$HOME/test_db"
echo "   done"

progress 4 "Stopping MySQL"
sudo systemctl stop mysql 2> /dev/null || true
sudo pkill -x mysqld 2> /dev/null || true

progress 5 "Purging the MySQL packages"
pkgs=$(dpkg -l 'mysql-*' 2> /dev/null | awk '/^ii/ {print $2}')
if [ -n "$pkgs" ]; then
  # shellcheck disable=SC2086
  sudo DEBIAN_FRONTEND=noninteractive apt-get purge -y $pkgs
  sudo apt-get autoremove -y --purge
else
  echo "   no MySQL packages installed"
fi

progress 6 "Deleting MySQL's data, configuration and logs"
sudo rm -rf /var/lib/mysql /var/lib/mysql-files /var/lib/mysql-keyring /var/lib/mysql-upgrade \
            /var/log/mysql /etc/mysql /run/mysqld
echo "   done"

progress 7 "Removing Oracle's MySQL APT repository"
sudo rm -f /etc/apt/sources.list.d/mysql.list /etc/apt/sources.list.d/mysql.sources \
           /etc/apt/trusted.gpg.d/mysql.gpg /usr/share/keyrings/mysql-apt-config.gpg \
           /etc/apt/keyrings/mysql.gpg
echo "   forgetting the repository choice"
echo "PURGE" | sudo debconf-communicate mysql-apt-config > /dev/null 2>&1 || true
sudo apt-get update > /dev/null 2>&1 && echo "   package lists refreshed"

progress_done
echo "Module 1 is undone."
