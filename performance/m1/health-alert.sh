#!/usr/bin/env bash
# Run the health check and post to Slack only when a check is over its threshold.
# Usage: bash ~/labs/m1/health-alert.sh
# Needs: lab.health_check (health-check.sql) and your webhook URL in ~/.config/mysql-alerts/webhook
set -euo pipefail

# Without a webhook URL there is nowhere to send the alert, so stop with an error.
WEBHOOK_FILE="${HOME}/.config/mysql-alerts/webhook"
if [ ! -s "${WEBHOOK_FILE}" ]; then
  echo "health-alert: no webhook URL in ${WEBHOOK_FILE}" >&2
  exit 1
fi

# -N: no column names, -B: no table borders, -r: print the JSON exactly as MySQL built it.
message=$(mysql --login-path=dba -N -B -r -e "CALL lab.health_check('slack')")

# The procedure returns nothing when every check is under its threshold: stay silent.
if [ -z "${message}" ]; then
  echo "health-alert: all checks OK"
  exit 0
fi

# Post the JSON to Slack. --fail turns an HTTP error into a non-zero exit code; --silent --show-error
# hides the progress meter but still prints errors.
curl --fail --silent --show-error \
     -H 'Content-type: application/json' \
     --data "${message}" \
     "$(cat "${WEBHOOK_FILE}")"
echo
echo "health-alert: alert sent to Slack"
