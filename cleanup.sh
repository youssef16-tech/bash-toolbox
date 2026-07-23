#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="/home/moussa/backups/clipvue"
KEEP_DAYS=7
JOURNAL_KEEP="14d"

echo "== System cleanup =="

echo "-> Disk usage before:"
df -h / | awk 'NR==1 || /\//'

echo "-> Trimming journal logs older than $JOURNAL_KEEP..."
sudo journalctl --vacuum-time="$JOURNAL_KEEP"

echo "-> Pruning ClipVue backups older than $KEEP_DAYS days..."
if [ -d "$BACKUP_DIR" ]; then
    find "$BACKUP_DIR" -name 'clipvue-*.db' -mtime +"$KEEP_DAYS" -delete
    echo "   done"
else
    echo "   no backup dir found, skipping"
fi

echo "-> Disk usage after:"
df -h / | awk 'NR==1 || /\//'

echo "== Cleanup complete =="
