#!/usr/bin/env bash
set -euo pipefail

REPO="/home/moussa/projects/clipvue-barber"
SERVICE="clipvue"

echo "== Deploying ClipVue =="

cd "$REPO"

echo "-> Pulling latest code..."
git pull

echo "-> Building release binary..."
cargo build --release

echo "-> Restarting service..."
sudo systemctl restart "$SERVICE"

echo "-> Verifying health..."
sleep 2
~/projects/bash-toolbox/health-check.sh

echo "== Deploy complete =="
