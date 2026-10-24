#!/usr/bin/env bash
# Simulate a forgotten transaction: open a transaction, sit idle, then delete old rows from
# lab.activity_log and never COMMIT.
# Usage: bash ~/labs/m2/blocker.sh [seconds] [delay]     (defaults: 36000 and 90)
#   seconds  how long the transaction stays open after the DELETE
#   delay    seconds the transaction is open and idle BEFORE the DELETE; during this time it holds no
#            locks and blocks nobody, so only the oldest_trx_s check can see it
# Run it in its own terminal (Terminal 3). Stop it early with Ctrl+C, which rolls the transaction back.
# Run the workload first: the DELETE removes rows older than one minute, so the workload needs
# to have been writing for that long, which the default delay covers.
# The delay is longer than the minute between cron runs on purpose: at least one scheduled health check
# then sees the open transaction (oldest_trx_s) before the DELETE blocks anyone.
set -euo pipefail

SECONDS_OPEN=${1:-36000}
DELAY=${2:-90}

echo "blocker: transaction open now, collides with the workload in ${DELAY} seconds, Ctrl+C to stop"
# The client starts a transaction (WITH CONSISTENT SNAPSHOT makes InnoDB start it at once; a plain BEGIN
# would not start it until the first statement), waits, runs the DELETE, then sits idle with the
# transaction still open.
( echo "START TRANSACTION WITH CONSISTENT SNAPSHOT;"
  sleep "${DELAY}"
  echo "DELETE FROM lab.activity_log WHERE logged_at < NOW() - INTERVAL 1 MINUTE;"
  sleep "${SECONDS_OPEN}" ) | mysql --login-path=dba
echo "blocker: finished"
