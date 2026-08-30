#!/usr/bin/env bash
set -euo pipefail

# Installs the three Claude Code design skills into ~/.claude/skills, which makes
# them available in every project on this machine (not just one repo).
#
#   impeccable                -- typography, color, spacing, anti-slop design fluency
#   design-motion-principles  -- motion/animation principles, create + audit modes
#   frontend-design           -- Anthropic's official frontend design skill
#
# Safe to re-run: each run pulls the latest version and reinstalls it.

SKILLS_DIR="$HOME/.claude/skills"
CACHE_DIR="$HOME/.claude/.skill-sources"

# repo url | path to the skill folder inside that repo | name to install it as
SKILLS=(
    "https://github.com/pbakaus/impeccable.git|.claude/skills/impeccable|impeccable"
    "https://github.com/kylezantos/design-motion-principles.git|skills/design-motion-principles|design-motion-principles"
    "https://github.com/anthropics/claude-code.git|plugins/frontend-design/skills/frontend-design|frontend-design"
)

echo "== Installing Claude Code design skills =="

if ! command -v git >/dev/null 2>&1; then
    echo "[FAIL] git is not installed"
    exit 1
fi

mkdir -p "$SKILLS_DIR" "$CACHE_DIR"

# --- fetch each repo, then copy just the skill folder into ~/.claude/skills ---
FAILED=0
for ENTRY in "${SKILLS[@]}"; do
    IFS='|' read -r REPO SUBDIR NAME <<< "$ENTRY"
    CACHE="$CACHE_DIR/$NAME"

    echo
    echo "-> $NAME ($REPO)"

    # Partial + sparse clone: these repos are large and we only want one folder.
    if [ -d "$CACHE/.git" ]; then
        echo "   updating cached source..."
        git -C "$CACHE" fetch --quiet --depth 1 origin HEAD
        git -C "$CACHE" reset --quiet --hard FETCH_HEAD
    else
        echo "   cloning source..."
        rm -rf "$CACHE"
        git clone --quiet --depth 1 --filter=blob:none --sparse "$REPO" "$CACHE"
    fi
    git -C "$CACHE" sparse-checkout set --no-cone "$SUBDIR" >/dev/null

    # Only replace a working install if the new copy actually looks like a skill.
    if [ ! -f "$CACHE/$SUBDIR/SKILL.md" ]; then
        echo "   [FAIL] no SKILL.md at $SUBDIR -- upstream layout changed, skipping"
        FAILED=1
        continue
    fi

    rm -rf "$SKILLS_DIR/$NAME"
    cp -R "$CACHE/$SUBDIR" "$SKILLS_DIR/$NAME"
    echo "   [OK]   installed to $SKILLS_DIR/$NAME"
done

echo
echo "-> Installed skills:"
for ENTRY in "${SKILLS[@]}"; do
    IFS='|' read -r _ _ NAME <<< "$ENTRY"
    if [ -f "$SKILLS_DIR/$NAME/SKILL.md" ]; then
        echo "   [OK]   $NAME"
    else
        echo "   [FAIL] $NAME (missing)"
        FAILED=1
    fi
done

if [ "$FAILED" -ne 0 ]; then
    echo
    echo "== Finished with errors =="
    exit 1
fi

echo
echo "== Done =="
echo "Restart Claude Code, then run /skills to confirm all three are listed."
echo "They load automatically on design work; you can also ask for one by name,"
echo "e.g. \"use the impeccable skill on this landing page\"."
