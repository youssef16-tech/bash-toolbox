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
| `install-design-skills.sh` | Installs three Claude Code design skills (impeccable, design-motion-principles, frontend-design) into `~/.claude/skills` so they're available in every project on this machine. Re-run to update. |

## Claude Code design skills

`install-design-skills.sh` sets up the three design skills globally, so Claude Code
uses them on any frontend work I do on this laptop:

| Skill | Source | What it adds |
|-------|--------|--------------|
| `impeccable` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) | Typography, color, spacing, layout and anti-"AI slop" design fluency. |
| `design-motion-principles` | [kylezantos/design-motion-principles](https://github.com/kylezantos/design-motion-principles) | Motion and interaction principles; builds components with motion or audits existing animation. |
| `frontend-design` | [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/plugins/frontend-design) | Anthropic's official frontend design skill for distinctive, intentional UI. |

```bash
./install-design-skills.sh
```

Installs into `~/.claude/skills/<name>/`, keeping the upstream git clones in
`~/.claude/.skill-sources/`. Restart Claude Code afterwards and check `/skills`.
The skills load on their own when a task looks like design work; you can also name
one directly ("use the impeccable skill on this page").

Note: `impeccable` and `design-motion-principles` are community projects, not
Anthropic-published — the installer pulls whatever is on their default branch.
`impeccable` also ships ~23 slash commands, which only come with the plugin
install (`/plugin marketplace add pbakaus/impeccable`, then pick it from `/plugin`);
this script installs the skill itself.

## Conventions
- Every script starts with `#!/usr/bin/env bash` and `set -euo pipefail`.
- Scripts are `chmod 700` (owner-only execute).
