#!/usr/bin/env bash
# Generate a steady SQL workload against the employees database.
# Usage: bash ~/labs/m1/workload.sh [sessions] [seconds]     (defaults: 4 sessions, 300 seconds)
# Run it in its own terminal; it keeps that terminal busy until it finishes. Stop it early with Ctrl+C.
# Stop at the first error (-e), on an unset variable (-u), or when a command in a pipe fails (pipefail).
set -euo pipefail

SESSIONS=${1:-4}
DURATION=${2:-300}
# Surnames for the unindexed search (every 10th round).
LAST_NAMES=(Facello Simmel Bamford Koblick Maliniak)

# The only table the workload writes to. The employees data itself is never changed.
mysql --login-path=dba -e "
  CREATE DATABASE IF NOT EXISTS lab;
  CREATE TABLE IF NOT EXISTS lab.activity_log (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    emp_no    INT NOT NULL,
    logged_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
  );"

# One session = one mysql connection fed an endless stream of statements until time is up.
session() {
  # SECONDS is a bash variable that counts the seconds since the script started.
  local end=$((SECONDS + DURATION)) i=0 emp
  while (( SECONDS < end )); do
    # RANDOM only goes up to 32767, so two of them are combined to reach the whole 10001-99999 range.
    emp=$((10001 + (RANDOM * 32768 + RANDOM) % 89999))   # an employee between 10001 and 99999
    echo "SELECT first_name, last_name, hire_date FROM employees WHERE emp_no = ${emp};"
    echo "SELECT salary, from_date, to_date FROM salaries WHERE emp_no = ${emp};"
    echo "SELECT d.dept_name FROM dept_emp de JOIN departments d ON d.dept_no = de.dept_no WHERE de.emp_no = ${emp} AND de.to_date = '9999-01-01';"
    echo "BEGIN; INSERT INTO lab.activity_log (emp_no) VALUES (${emp}); COMMIT;"
    if (( ++i % 10 == 0 )); then   # every 10th round: a search on a column with no index
      echo "SELECT COUNT(*) FROM employees WHERE last_name = '${LAST_NAMES[RANDOM % 5]}';"
    fi
  # --force keeps going after a failed statement (for example a lock wait timeout); the output is thrown away.
  done | mysql --login-path=dba --force employees > /dev/null
}

# Ctrl+C stops every session, not just this script: the sessions run in the background,
# where bash ignores Ctrl+C, so the trap ends the whole process group instead.
trap 'trap - INT TERM; echo "workload: stopped"; kill 0' INT TERM

# Start all sessions in the background, then wait for them to finish.
echo "workload: ${SESSIONS} sessions for ${DURATION} seconds"
for _ in $(seq "${SESSIONS}"); do
  session &
done
wait
echo "workload: finished"
