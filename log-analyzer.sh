#!/usr/bin/env bash
set -euo pipefail

SERVICE="clipvue"

# grab all request log lines once, store in a variable
REQUESTS="$(journalctl -u "$SERVICE" --no-pager | grep 'middleware::logger' || true)"

TOTAL="$(printf '%s\n' "$REQUESTS" | grep -c . || true)"

echo "== ClipVue log analysis =="
echo "Total requests: $TOTAL"
echo
echo "By status code (count | code):"
printf '%s\n' "$REQUESTS" | awk -F'"' '{print $3}' | awk '{print $1}' | sort | uniq -c | sort -rn
echo
echo "Top 5 endpoints (count | path):"
printf '%s\n' "$REQUESTS" | awk -F'"' '{print $2}' | awk '{print $2}' | sort | uniq -c | sort -rn | head -5
