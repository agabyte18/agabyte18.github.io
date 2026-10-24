#!/usr/bin/env bash
# Simulate a busy "find an employee by surname" page: many visitors search at the same time.
# Usage: bash ~/labs/m2/search-page.sh [visitors] [seconds]     (defaults: 30 visitors, 36000 seconds)
# Run it in its own terminal (Terminal 3). Stop it early with Ctrl+C.
set -euo pipefail

VISITORS=${1:-30}
DURATION=${2:-36000}
LAST_NAMES=(Facello Simmel Bamford Koblick Maliniak Preusig Zielinski Kalloufi Peac Piveteau)

# One visitor = one connection that searches for a surname, then pauses a moment before the next search.
visitor() {
  local end=$((SECONDS + DURATION))
  while (( SECONDS < end )); do
    echo "SELECT COUNT(*) FROM employees WHERE last_name = '${LAST_NAMES[RANDOM % 10]}';"
    sleep 0.2   # the pause is in the shell, so an idle visitor is not a running statement on the server
  done | mysql --login-path=dba --force employees > /dev/null
}

# Ctrl+C stops every visitor, not just this script (same trap as workload.sh).
trap 'trap - INT TERM; echo "search-page: stopped"; kill 0' INT TERM

echo "search-page: ${VISITORS} visitors for ${DURATION} seconds"
for _ in $(seq "${VISITORS}"); do
  visitor &
done
wait
echo "search-page: finished"
