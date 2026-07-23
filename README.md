# bash-toolbox

A collection of practical Bash scripts I use to operate my own Linux machine and my
Rust web app (ClipVue). Built while learning DevOps.

## Scripts

| Script | What it does |
|--------|--------------|
| `backup-db.sh` | Safe, timestamped SQLite backup of ClipVue's database, prunes copies older than 7 days. Runs nightly via a systemd timer. |

## Conventions
- Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Scripts are `chmod 700` (owner-only execute).
