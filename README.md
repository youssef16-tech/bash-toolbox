# bash-toolbox

A collection of practical Bash scripts I use to operate my own Linux machine and my
Rust web app (ClipVue). Built while learning DevOps.

## Scripts

| Script | What it does |
|--------|--------------|
| `backup-db.sh` | Safe, timestamped SQLite backup of ClipVue's database, prunes copies older than 7 days. Runs nightly via a systemd timer. |
| `health-check.sh` | Checks that the ClipVue systemd service is active and its HTTP endpoint returns 200. Exits non-zero on failure (monitoring-friendly). |
| `log-analyzer.sh` | Parses ClipVue's journald request logs: total requests, breakdown by HTTP status code, and top 5 requested endpoints. |
| `deploy.sh` | One-command deploy: git pull, cargo build --release, restart the systemd service, then run the health check. Stops before restarting if the build fails. |
| `cleanup.sh` | Reclaims disk space: reports usage, vacuums journal logs older than 14 days, prunes old backups. Shows before/after disk usage. |

## Conventions
- Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Scripts are `chmod 700` (owner-only execute).
