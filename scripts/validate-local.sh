#!/usr/bin/env bash
set -euo pipefail

# =========================================================================
# validate-local.sh — Active local validation helper for the scaffold.
# Usage: bash scripts/validate-local.sh
#
# Validation order:
# - lint -> typecheck -> test -> coverage -> build
# - Only run scripts that exist in package.json.
# - Coverage enforcement is opt-in via .agent-cache/agent_config.json.
# - On failure, write failure_summary.md with the last ~160 lines.
# - On coverage below target, write coverage_hint.md for follow-up.
# - Runtime cache/state belongs in .agent-cache/.
# - This helper never commits, pushes, opens PRs, or bypasses git hooks.
# =========================================================================

notify() {
  local message="$1"
  local title="Copilot Agent"
  if [[ "${AGENT_SILENT_MODE:-false}" != "true" ]]; then
    case "$OSTYPE" in
      darwin*)
        osascript -e "display notification \"$message\" with title \"$title\" sound name \"Submarine\""
        if [[ "$message" =~ "FAILED" || "$message" =~ "CRITICAL" ]]; then
          osascript -e "tell app \"System Events\" to display dialog \"$message\" with title \"$title\" buttons {\"OK\"} default button \"OK\" with icon caution" &
        fi ;;
      linux*)
        if command -v notify-send &>/dev/null; then
          notify-send "$title" "$message" -i utilities-terminal
        fi ;;
      msys*|cygwin*|mingw*)
        if command -v powershell.exe &>/dev/null; then
          powershell.exe -Command "[Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('$message', '$title')" &
        fi ;;
    esac
  fi
}

DOCS_DIR="docs"
CACHE_DIR=".agent-cache"
STATE_FILE="$CACHE_DIR/AGENT_STATE.json"
DECISIONS_FILE="$DOCS_DIR/DECISIONS.md"
LAST_RUN_DIR="$CACHE_DIR/last-run"
RUNTIME_HELPER="scripts/agent-runtime.py"
TIMESTAMP="$(date -u '+%Y-%m-%d %H:%M')"

mkdir -p "$DOCS_DIR" "$LAST_RUN_DIR"

if [ ! -f "$DECISIONS_FILE" ]; then
  echo "# Agent Decisions Log" > "$DECISIONS_FILE"
  echo "" >> "$DECISIONS_FILE"
  echo "> Auto-maintained by the agent ecosystem. Do not delete." >> "$DECISIONS_FILE"
fi

if [ -f "$RUNTIME_HELPER" ]; then
  python3 "$RUNTIME_HELPER" init >/dev/null 2>&1 || true
  python3 "$RUNTIME_HELPER" cleanup-stale-locks >/dev/null 2>&1 || true
  if ! python3 "$RUNTIME_HELPER" lock acquire qa --owner validate-local --ttl 1800 --resource docs/QA_REPORT.md >/dev/null 2>&1; then
    echo "[ROLE: QA] Validation skipped: another QA run already holds the active lock." | tee -a "$LAST_RUN_DIR/validate.log"
    echo "- [$TIMESTAMP] QA: validation skipped (qa lock already held)." >> "$DECISIONS_FILE"
    exit 0
  fi
fi

cleanup_runtime() {
  if [ -f "$RUNTIME_HELPER" ]; then
    python3 "$RUNTIME_HELPER" lock release qa --owner validate-local >/dev/null 2>&1 || true
  fi
}

trap cleanup_runtime EXIT

detect_pkg_manager() {
  if [ -f "yarn.lock" ]; then
    echo "yarn"
  elif [ -f "pnpm-lock.yaml" ]; then
    echo "pnpm"
  elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
    echo "bun"
  elif [ -f "package-lock.json" ]; then
    echo "npm"
  else
    echo "npm"
  fi
}

has_pkg_script() {
  local script_name="$1"
  if [ ! -f "package.json" ]; then
    echo "no"
    return
  fi
  python3 -c "
import json, sys
try:
    with open('package.json') as f:
        pkg = json.load(f)
    print('yes' if sys.argv[1] in pkg.get('scripts', {}) else 'no')
except:
    print('no')
" "$script_name"
}

run_pkg_script() {
  local script_name="$1"
  local pkg_mgr="$2"
  local log_file="$3"

  if [ "$pkg_mgr" = "npm" ]; then
    $pkg_mgr run "$script_name" 2>&1 | tee -a "$log_file"
  else
    $pkg_mgr "$script_name" 2>&1 | tee -a "$log_file"
  fi
  return "${PIPESTATUS[0]}"
}

detect_hook_manager() {
  python3 << 'HOOKEOF'
import json, os
from datetime import datetime, timezone

CACHE_DIR = ".agent-cache"
STATE_FILE = os.path.join(CACHE_DIR, "AGENT_STATE.json")

detected = "unknown"
evidence = []

if os.path.isdir(".husky"):
    detected = "husky"
    evidence.append(".husky/ directory exists")
elif os.path.isfile("package.json"):
    try:
        with open("package.json") as f:
            content = f.read()
        if '"husky"' in content:
            detected = "husky"
            evidence.append("package.json references husky")
    except:
        pass

if os.path.isfile("lefthook.yml") or os.path.isfile("lefthook.yaml"):
    detected = "lefthook"
    evidence.append("lefthook config exists")
if os.path.isdir(".lefthook"):
    detected = "lefthook"
    evidence.append(".lefthook/ directory exists")

if os.path.isfile(".pre-commit-config.yaml"):
    detected = "pre-commit"
    evidence.append(".pre-commit-config.yaml exists")

hooks_dir = os.path.join(".git", "hooks")
if os.path.isdir(hooks_dir):
    for name in os.listdir(hooks_dir):
        if name.endswith(".sample"):
            continue
        hook_path = os.path.join(hooks_dir, name)
        if os.path.isfile(hook_path) and os.access(hook_path, os.X_OK):
            if detected == "unknown":
                detected = "manual"
            evidence.append(f".git/hooks/{name} is executable")

os.makedirs(CACHE_DIR, exist_ok=True)
state = {}
if os.path.isfile(STATE_FILE):
    try:
        with open(STATE_FILE) as f:
            state = json.load(f)
    except:
        state = {}

state["hook_manager"] = {
    "detected": detected,
    "evidence": evidence,
    "checked_at": datetime.now(timezone.utc).isoformat(),
}

with open(STATE_FILE, "w") as f:
    json.dump(state, f, indent=2)

if evidence:
    print(f"[hook-manager] Detected: {detected} ({', '.join(evidence)})")
else:
    print("[hook-manager] No hook manager detected.")
HOOKEOF
}

echo ""
echo "[ROLE: QA] Starting validation..."

VALIDATE_LOG="$LAST_RUN_DIR/validate.log"
FAILURE_SUMMARY="$LAST_RUN_DIR/failure_summary.md"

: > "$VALIDATE_LOG"
rm -f "$FAILURE_SUMMARY"

FAILED=false
FAILED_STEP=""
PKG_MGR="$(detect_pkg_manager)"

detect_hook_manager | tee -a "$VALIDATE_LOG"

if [ -f "$RUNTIME_HELPER" ]; then
  python3 "$RUNTIME_HELPER" budget record ci-checks broader-validation \
    --justification "explicit validate-local invocation" \
    --scope "package.json,tsconfig.*,src/**,scripts/**" >/dev/null 2>&1 || true
fi

if [ ! -f "package.json" ]; then
  echo "[ROLE: QA] No package.json found. Validation skipped (pass)." | tee -a "$VALIDATE_LOG"
  echo "- [$TIMESTAMP] QA: validation skipped (no package.json)." >> "$DECISIONS_FILE"
  exit 0
fi

if [ "$(has_pkg_script lint)" = "yes" ]; then
  echo "[ROLE: QA] Running lint..." | tee -a "$VALIDATE_LOG"
  if ! run_pkg_script lint "$PKG_MGR" "$VALIDATE_LOG"; then
    FAILED=true
    FAILED_STEP="lint"
  else
    echo "[ROLE: QA] Lint passed." | tee -a "$VALIDATE_LOG"
  fi
else
  echo "[ROLE: QA] No lint script found (skipped)." | tee -a "$VALIDATE_LOG"
fi

if [ "$FAILED" = false ] && [ "$(has_pkg_script typecheck)" = "yes" ]; then
  echo "[ROLE: QA] Running typecheck..." | tee -a "$VALIDATE_LOG"
  if ! run_pkg_script typecheck "$PKG_MGR" "$VALIDATE_LOG"; then
    FAILED=true
    FAILED_STEP="typecheck"
  else
    echo "[ROLE: QA] Typecheck passed." | tee -a "$VALIDATE_LOG"
  fi
fi

if [ "$FAILED" = false ] && [ "$(has_pkg_script test)" = "yes" ]; then
  echo "[ROLE: QA] Running tests..." | tee -a "$VALIDATE_LOG"
  if ! run_pkg_script test "$PKG_MGR" "$VALIDATE_LOG"; then
    FAILED=true
    FAILED_STEP="test"
  else
    echo "[ROLE: QA] Tests passed." | tee -a "$VALIDATE_LOG"
  fi
else
  if [ "$FAILED" = false ]; then
    echo "[ROLE: QA] No test script found (skipped)." | tee -a "$VALIDATE_LOG"
  fi
fi

if [ "$FAILED" = false ]; then
  COVERAGE_TARGET=""
  AGENT_CONFIG_FILE="$CACHE_DIR/agent_config.json"
  if [ -f "$AGENT_CONFIG_FILE" ]; then
    COVERAGE_TARGET="$(python3 -c "
import json, sys
try:
    with open(sys.argv[1]) as f:
        d = json.load(f)
    t = d.get('coverage_target')
    print(t if t else '')
except:
    print('')
" "$AGENT_CONFIG_FILE")"
  fi

  if [ -n "$COVERAGE_TARGET" ] && [ "$(has_pkg_script coverage)" = "yes" ]; then
    echo "[ROLE: QA] Running coverage (target: ${COVERAGE_TARGET}%)..." | tee -a "$VALIDATE_LOG"
    COVERAGE_OUTPUT="$($PKG_MGR run coverage 2>&1)" || true
    echo "$COVERAGE_OUTPUT" | tee -a "$VALIDATE_LOG"

    COV_PCT="$(echo "$COVERAGE_OUTPUT" | python3 -c "
import sys, re
text = sys.stdin.read()
m = re.search(r'(?:lines|all files|statements)\s*[:|]\s*(\d+(?:\.\d+)?)\s*%?', text, re.IGNORECASE)
if m:
    print(m.group(1))
else:
    m = re.search(r'(\d+(?:\.\d+)?)\s*%', text)
    print(m.group(1) if m else '')
")"

    if [ -n "$COV_PCT" ]; then
      echo "[ROLE: QA] Coverage: ${COV_PCT}% (target: ${COVERAGE_TARGET}%)" | tee -a "$VALIDATE_LOG"
      BELOW="$(python3 -c "print('yes' if float('$COV_PCT') < float('$COVERAGE_TARGET') else 'no')")"
      if [ "$BELOW" = "yes" ]; then
        echo "[ROLE: QA] Coverage below target!" | tee -a "$VALIDATE_LOG"
        FAILED=true
        FAILED_STEP="coverage"

        COVERAGE_HINT="$LAST_RUN_DIR/coverage_hint.md"
        {
          echo "# Coverage Hint"
          echo ""
          echo "**Current:** ${COV_PCT}% | **Target:** ${COVERAGE_TARGET}%"
          echo ""
          echo "## Under-covered files (from coverage output)"
          echo ""
          echo "$COVERAGE_OUTPUT" | grep -E '^\s*\S+\.(ts|tsx|js|jsx|astro)\s' | head -20 | sed 's/^/- /' || echo "- (unable to parse file list)"
        } > "$COVERAGE_HINT"
        echo "[ROLE: QA] Coverage hint written to $COVERAGE_HINT" | tee -a "$VALIDATE_LOG"
      else
        echo "[ROLE: QA] Coverage meets target." | tee -a "$VALIDATE_LOG"
      fi
    else
      echo "[ROLE: QA] Could not parse coverage percentage. Skipping enforcement." | tee -a "$VALIDATE_LOG"
    fi
  elif [ -n "$COVERAGE_TARGET" ]; then
    echo "[ROLE: QA] Coverage target set (${COVERAGE_TARGET}%) but no 'coverage' script in package.json (skipped)." | tee -a "$VALIDATE_LOG"
  fi
fi

if [ "$FAILED" = false ] && [ "$(has_pkg_script build)" = "yes" ]; then
  echo "[ROLE: DEVOPS] Running build..." | tee -a "$VALIDATE_LOG"
  if ! run_pkg_script build "$PKG_MGR" "$VALIDATE_LOG"; then
    FAILED=true
    FAILED_STEP="build"
  else
    echo "[ROLE: DEVOPS] Build passed." | tee -a "$VALIDATE_LOG"
  fi
fi

if [ "$FAILED" = true ]; then
  echo "" | tee -a "$VALIDATE_LOG"
  echo "[ROLE: QA] VALIDATION FAILED at step: $FAILED_STEP" | tee -a "$VALIDATE_LOG"
  {
    echo "# Failure Summary"
    echo ""
    echo "**Failed step:** \`$FAILED_STEP\`"
    echo "**Timestamp:** $TIMESTAMP"
    echo ""
    echo "## Relevant output (last ~160 lines)"
    echo ""
    echo '```'
    tail -n 160 "$VALIDATE_LOG"
    echo '```'
    echo ""
    echo "## File paths mentioned in output"
    echo ""
    grep -oE '[a-zA-Z0-9_./-]+\.[a-zA-Z]{1,5}(:[0-9]+)?' "$VALIDATE_LOG" \
      | grep -E '\.(ts|tsx|js|jsx|json|astro|css|md|mjs|cjs)' \
      | sort -u \
      | head -30 \
      | sed 's/^/- /' \
      || echo "- (none detected)"
  } > "$FAILURE_SUMMARY"

  echo "- [$TIMESTAMP] QA: validation FAILED at \`$FAILED_STEP\`." >> "$DECISIONS_FILE"
  notify "VALIDATION FAILED at $FAILED_STEP"
  exit 1
fi

echo ""
echo "[ROLE: QA] All validation steps passed."
echo "- [$TIMESTAMP] QA: validation passed (lint/typecheck/test/build)." >> "$DECISIONS_FILE"
notify "Validation passed"
exit 0
