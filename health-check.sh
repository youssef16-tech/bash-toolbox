#!/usr/bin/env bash
set -euo pipefail

# --- what we're checking ---
SERVICE="clipvue"
URL="http://localhost:8080/"
TIMEOUT=5

echo "== ClipVue health check =="

# --- 1. is the systemd service active? ---
if systemctl is-active --quiet "$SERVICE"; then
    echo "[OK]   service '$SERVICE' is active"
else
    echo "[FAIL] service '$SERVICE' is NOT active"
    exit 1
fi

# --- 2. does the HTTP endpoint respond with 200? ---
CODE="$(curl -s -o /dev/null -w '%{http_code}' --max-time "$TIMEOUT" "$URL" || echo "000")"
if [ "$CODE" = "200" ]; then
    echo "[OK]   $URL returned HTTP $CODE"
else
    echo "[FAIL] $URL returned HTTP $CODE"
    exit 1
fi

echo "All checks passed. ClipVue is healthy."
