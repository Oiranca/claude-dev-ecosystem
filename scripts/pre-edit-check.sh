#!/usr/bin/env bash
# pre-edit-check.sh
# Invoked by hooks/hooks.json before Write, Edit, and MultiEdit tool calls.
# Runs fast, non-blocking safety checks before any file modification.
set -euo pipefail

FILE="${1:-}"

if [[ -z "$FILE" ]]; then
  exit 0
fi

# ── 1. Never modify files in protected directories ─────────────────────────
PROTECTED_PATTERNS=(
  "node_modules/"
  ".git/"
  "dist/"
  "build/"
  ".next/"
  ".turbo/"
  "vendor/"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE" == *"$pattern"* ]]; then
    echo "[pre-edit-check] BLOCKED: '$FILE' is inside a protected directory ($pattern)." >&2
    exit 1
  fi
done

# ── 2. Never modify secret or credential files ─────────────────────────────
SENSITIVE_NAMES=(
  ".env"
  ".env.local"
  ".env.production"
  ".env.development"
  ".env.test"
  "id_rsa"
  "id_ed25519"
  "*.pem"
  "*.key"
  "*.p12"
  "*.pfx"
  "secrets.json"
  "credentials.json"
  "service-account.json"
)

BASENAME="$(basename "$FILE")"
for name in "${SENSITIVE_NAMES[@]}"; do
  # Glob-style match using case
  case "$BASENAME" in
    $name)
      echo "[pre-edit-check] BLOCKED: '$FILE' matches a sensitive filename pattern ($name)." >&2
      exit 1
      ;;
  esac
done

# Exact match for .env (basename check)
if [[ "$BASENAME" == ".env" ]]; then
  echo "[pre-edit-check] BLOCKED: Direct edits to .env are not allowed via automated tools." >&2
  exit 1
fi

# ── 3. Lock file check ─────────────────────────────────────────────────────
LOCK_DIR=".agent-cache/locks"
if [[ -d "$LOCK_DIR" ]]; then
  # Check for any lock that matches this file's artifact name
  ARTIFACT_BASE="$(basename "$FILE" .md)"
  LOCK_FILE="$LOCK_DIR/${ARTIFACT_BASE}.lock"
  if [[ -f "$LOCK_FILE" ]]; then
    LOCK_AGE=$(( $(date +%s) - $(stat -f %m "$LOCK_FILE" 2>/dev/null || stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0) ))
    # Stale threshold: 30 minutes (1800 seconds)
    if [[ "$LOCK_AGE" -lt 1800 ]]; then
      echo "[pre-edit-check] WARNING: '$FILE' has an active lock ($LOCK_FILE, age ${LOCK_AGE}s). Proceeding but verify this is intentional." >&2
    fi
  fi
fi

# ── 4. Warn on large doc rewrites ──────────────────────────────────────────
DOCS_ARTIFACTS=(
  "docs/STACK_PROFILE.md"
  "docs/INVENTORY.md"
  "docs/ARCHITECTURE.md"
  "docs/QA_REPORT.md"
  "docs/SECURITY_REPORT.md"
)

for artifact in "${DOCS_ARTIFACTS[@]}"; do
  if [[ "$FILE" == *"$artifact" ]] && [[ -f "$FILE" ]]; then
    LINE_COUNT=$(wc -l < "$FILE" 2>/dev/null || echo 0)
    if [[ "$LINE_COUNT" -gt 50 ]]; then
      echo "[pre-edit-check] WARNING: About to modify an existing agent-owned artifact '$FILE' ($LINE_COUNT lines). Ensure the owning agent authorized this change." >&2
    fi
  fi
done

exit 0
