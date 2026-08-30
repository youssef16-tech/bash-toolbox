#!/usr/bin/env bash
set -euo pipefail

# Installs the three Claude Code design skills into ~/.claude, which makes them
# available in every project on this machine (not just one repo).
#
#   impeccable                -- typography, color, spacing, anti-slop design fluency
#   design-motion-principles  -- motion/animation principles, create + audit modes
#   frontend-design           -- Anthropic's official frontend design skill
#
# impeccable is installed as a plugin by default, which brings its agents, hooks
# and /impeccable slash commands along with the skill. Pass --impeccable=skill to
# install just the SKILL.md instead (no claude CLI needed).
#
# Safe to re-run: each run pulls the latest version and reinstalls it.

SKILLS_DIR="$HOME/.claude/skills"
CACHE_DIR="$HOME/.claude/.skill-sources"
IMPECCABLE_MODE="plugin"

# repo url | path to the skill folder inside that repo | name to install it as
SKILLS=(
    "https://github.com/kylezantos/design-motion-principles.git|skills/design-motion-principles|design-motion-principles"
    "https://github.com/anthropics/claude-code.git|plugins/frontend-design/skills/frontend-design|frontend-design"
)
IMPECCABLE_AS_SKILL="https://github.com/pbakaus/impeccable.git|.claude/skills/impeccable|impeccable"

usage() {
    cat <<'USAGE'
Usage: install-design-skills.sh [--impeccable=plugin|skill]

  --impeccable=plugin  (default) install impeccable as a Claude Code plugin:
                       skill + agents + hooks + /impeccable slash commands.
                       Requires the claude CLI.
  --impeccable=skill   install only impeccable's SKILL.md into ~/.claude/skills.
USAGE
}

for ARG in "$@"; do
    case "$ARG" in
        --impeccable=plugin|--impeccable=skill) IMPECCABLE_MODE="${ARG#--impeccable=}" ;;
        -h|--help) usage; exit 0 ;;
        *) echo "unknown option: $ARG" >&2; usage >&2; exit 2 ;;
    esac
done

echo "== Installing Claude Code design skills =="

if ! command -v git >/dev/null 2>&1; then
    echo "[FAIL] git is not installed"
    exit 1
fi

if [ "$IMPECCABLE_MODE" = "plugin" ] && ! command -v claude >/dev/null 2>&1; then
    echo "[WARN] claude CLI not found -- installing impeccable as a plain skill instead"
    IMPECCABLE_MODE="skill"
fi

if [ "$IMPECCABLE_MODE" = "skill" ]; then
    SKILLS+=("$IMPECCABLE_AS_SKILL")
fi

mkdir -p "$SKILLS_DIR" "$CACHE_DIR"

FAILED=0

# --- fetch a repo, then copy just the skill folder into ~/.claude/skills ---
install_skill() {
    REPO="$1"; SUBDIR="$2"; NAME="$3"
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
        return
    fi

    rm -rf "$SKILLS_DIR/$NAME"
    cp -R "$CACHE/$SUBDIR" "$SKILLS_DIR/$NAME"
    echo "   [OK]   installed to $SKILLS_DIR/$NAME"
}

# --- impeccable via the plugin system: skill + agents + hooks + commands ---
install_impeccable_plugin() {
    echo
    echo "-> impeccable (plugin from pbakaus/impeccable)"

    # --sparse limits the checkout to the plugin package instead of the whole repo.
    claude plugin marketplace add pbakaus/impeccable --sparse .claude-plugin plugin 2>&1 | sed 's/^/   /'
    claude plugin marketplace update impeccable 2>&1 | sed 's/^/   /'
    claude plugin install impeccable@impeccable --scope user --yes 2>&1 | sed 's/^/   /'
    claude plugin update impeccable@impeccable 2>&1 | sed 's/^/   /'

    # A leftover copy from an earlier --impeccable=skill run would double the skill up.
    if [ -d "$SKILLS_DIR/impeccable" ]; then
        rm -rf "$SKILLS_DIR/impeccable" "$CACHE_DIR/impeccable"
        echo "   removed the older standalone copy in $SKILLS_DIR/impeccable"
    fi
    echo "   [OK]   installed as plugin impeccable@impeccable (user scope)"
}

for ENTRY in "${SKILLS[@]}"; do
    IFS='|' read -r REPO SUBDIR NAME <<< "$ENTRY"
    install_skill "$REPO" "$SUBDIR" "$NAME"
done

if [ "$IMPECCABLE_MODE" = "plugin" ]; then
    install_impeccable_plugin
fi

echo
echo "-> Installed:"
for ENTRY in "${SKILLS[@]}"; do
    IFS='|' read -r _ _ NAME <<< "$ENTRY"
    if [ -f "$SKILLS_DIR/$NAME/SKILL.md" ]; then
        echo "   [OK]   $NAME (skill)"
    else
        echo "   [FAIL] $NAME (missing)"
        FAILED=1
    fi
done
if [ "$IMPECCABLE_MODE" = "plugin" ]; then
    if claude plugin list 2>/dev/null | grep -q 'impeccable@impeccable'; then
        echo "   [OK]   impeccable (plugin)"
    else
        echo "   [FAIL] impeccable (plugin not listed)"
        FAILED=1
    fi
fi

if [ "$FAILED" -ne 0 ]; then
    echo
    echo "== Finished with errors =="
    exit 1
fi

echo
echo "== Done =="
echo "Restart Claude Code, then check /skills (and /plugin for impeccable)."
echo "They load automatically on design work; you can also ask for one by name,"
echo "e.g. \"use the impeccable skill on this landing page\", or run /impeccable polish."
