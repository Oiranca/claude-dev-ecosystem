#!/usr/bin/env bash
# caveman — UserPromptSubmit hook: track mode changes + per-turn reinforcement
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
FLAG="$CLAUDE_DIR/.caveman-active"
VALID_MODES="off lite full ultra wenyan-lite wenyan wenyan-full wenyan-ultra commit review compress"

INPUT=$(cat 2>/dev/null) || INPUT=""
[ -z "$INPUT" ] && exit 0

PROMPT=$(python3 -c "
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print((d.get('prompt') or '').lower().strip())
except:
    pass
" <<< "$INPUT" 2>/dev/null) || PROMPT=""

MODE=""

# /caveman slash commands
if echo "$PROMPT" | grep -qE "^/(caveman)"; then
    CMD=$(echo "$PROMPT" | awk '{print $1}')
    ARG=$(echo "$PROMPT" | awk '{print $2}')
    case "$CMD" in
        /caveman-commit)  MODE="commit" ;;
        /caveman-review)  MODE="review" ;;
        /caveman-compress|/caveman:caveman-compress) MODE="compress" ;;
        /caveman|/caveman:caveman)
            case "$ARG" in
                lite)         MODE="lite" ;;
                ultra)        MODE="ultra" ;;
                wenyan-lite)  MODE="wenyan-lite" ;;
                wenyan|wenyan-full) MODE="wenyan" ;;
                wenyan-ultra) MODE="wenyan-ultra" ;;
                off)          MODE="off" ;;
                *)            MODE="${CAVEMAN_DEFAULT_MODE:-ultra}" ;;
            esac ;;
    esac
fi

# Natural language activation
if echo "$PROMPT" | grep -qE "(activate|enable|turn on|start|talk like).*caveman|caveman.*(mode|activate|enable|turn on|start)"; then
    if ! echo "$PROMPT" | grep -qE "(stop|disable|turn off|deactivate)"; then
        DEF="${CAVEMAN_DEFAULT_MODE:-ultra}"
        [ "$DEF" != "off" ] && MODE="$DEF"
    fi
fi

# Natural language deactivation
if echo "$PROMPT" | grep -qE "(stop|disable|deactivate|turn off).*caveman|caveman.*(stop|disable|deactivate|turn off)|normal mode"; then
    MODE="off"
fi

# Apply
if [ -n "$MODE" ]; then
    if [ "$MODE" = "off" ]; then
        rm -f "$FLAG"
    else
        if echo " $VALID_MODES " | grep -q " $MODE "; then
            # Guard: skip if FLAG is a symlink or any non-regular file
            if [ -e "$FLAG" ] && [ ! -f "$FLAG" ]; then
                : # not a regular file — skip write
            elif [ -L "$FLAG" ]; then
                : # symlink — skip write
            else
                # Atomic write: write to a tmpfile in the same directory, then rename
                _TMP=$(mktemp "$(dirname "$FLAG")/.caveman-active.XXXXXX")
                printf '%s' "$MODE" > "$_TMP"
                chmod 600 "$_TMP" 2>/dev/null || true
                mv -f "$_TMP" "$FLAG"
            fi
        fi
    fi
fi

# Per-turn reinforcement (skip independent modes)
INDEPENDENT="commit review compress"
if [ -f "$FLAG" ] && [ ! -L "$FLAG" ]; then
    ACTIVE=$(tr -d '[:space:]' < "$FLAG" 2>/dev/null | head -c 64)
    if echo " $VALID_MODES " | grep -q " $ACTIVE "; then
        if ! echo " $INDEPENDENT " | grep -q " $ACTIVE "; then
            python3 -c "
import json
print(json.dumps({'hookSpecificOutput': {'hookEventName': 'UserPromptSubmit', 'additionalContext': 'CAVEMAN MODE ACTIVE ($ACTIVE). Drop articles/filler/pleasantries/hedging. Fragments OK. Code/commits/security: write normal.'}}))
"
        fi
    fi
fi
