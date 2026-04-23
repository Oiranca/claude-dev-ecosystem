#!/usr/bin/env bash
# Caveman mode activation hook for Claude Code (SessionStart)
# Writes flag file for statusline, then emits caveman ruleset as session context.

set -euo pipefail

MODE="${CAVEMAN_DEFAULT_MODE:-ultra}"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SKILL_FILE="$CLAUDE_DIR/extensions/caveman/skills/caveman/SKILL.md"

# Write flag for statusline — guard against symlinks and non-regular files
_FLAG="${CLAUDE_DIR}/.caveman-active"
if [ -e "$_FLAG" ] && [ ! -f "$_FLAG" ]; then
    : # not a regular file — skip write
elif [ -L "$_FLAG" ]; then
    : # symlink — skip write
else
    # Atomic write: write to a tmpfile in the same directory, then rename
    _TMP=$(mktemp "${CLAUDE_DIR}/.caveman-active.XXXXXX")
    echo "${MODE}" > "$_TMP"
    chmod 600 "$_TMP" 2>/dev/null || true
    mv -f "$_TMP" "$_FLAG"
fi

echo "CAVEMAN MODE ACTIVE — level: ${MODE}"
echo ""

if [[ -f "$SKILL_FILE" ]]; then
    # Strip YAML frontmatter (content between first and second ---) and print the rest
    awk 'BEGIN{n=0} /^---/{n++; if(n==2){p=1; next}} p{print}' "$SKILL_FILE"
else
    # Fallback minimal ruleset
    printf 'Respond terse like smart caveman. All technical substance stay. Only fluff die.\n\n'
    printf '## Persistence\n\nACTIVE EVERY RESPONSE. No revert after many turns. Off only: "stop caveman" / "normal mode".\n\n'
    printf '## Rules\n\nDrop: articles (a/an/the), filler, pleasantries, hedging. Fragments OK. Technical terms exact. Code blocks unchanged.\n'
fi
