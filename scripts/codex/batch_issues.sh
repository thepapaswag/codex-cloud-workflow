#!/usr/bin/env bash
set -euo pipefail

CSV=${1:-codex_tasks.csv}
TEMPLATE=${2:-templates/issue_body.md}
LABELS=${LABELS:-"codex:ready,automation"}

# CSV schema (minimal): title,size,branch,allowlist,tests,body_or_file[,preamble_env,preamble_setup,preamble_tasks,preamble_artifacts]
# Notes:
# - If column 6 points to a readable file path, its contents become the body/spec; otherwise it is treated as literal text.
# - Preamble columns are optional; if present they are injected into the template placeholders.

if [ ! -f "$CSV" ]; then
  echo "CSV not found: $CSV" >&2
  exit 1
fi

tmpfile() { mktemp "/tmp/codex_issue_body.XXXXXX.md"; }

# shellcheck disable=SC2162
{
  read header || true # skip header
  while IFS=, read TITLE SIZE BRANCH ALLOWLIST TESTS BODY_OR_FILE PRE_ENV PRE_SETUP PRE_TASKS PRE_ARTIFACTS; do
    [ -n "${TITLE:-}" ] || continue

    if [ -n "${BODY_OR_FILE:-}" ] && [ -f "$BODY_OR_FILE" ]; then
      BODY=$(cat "$BODY_OR_FILE")
    else
      BODY="${BODY_OR_FILE:-}"
    fi

    export OBJECTIVE="$TITLE"
    export SPEC="$BODY"
    export BRANCH="${BRANCH:-}"
    export ALLOWLIST="${ALLOWLIST:-}"
    export TESTS="${TESTS:-}"
    export PREAMBLE_ENV="${PRE_ENV:-}"
    export PREAMBLE_SETUP="${PRE_SETUP:-}"
    export PREAMBLE_TASKS="${PRE_TASKS:-}"
    export PREAMBLE_ARTIFACTS="${PRE_ARTIFACTS:-}"

    BODY_TXT=$(envsubst < "$TEMPLATE")
    TMP=$(tmpfile)
    printf "%s\n" "$BODY_TXT" > "$TMP"

    gh issue create \
      --title "[Codex] $TITLE" \
      --label "$LABELS,size:$SIZE" \
      --body-file "$TMP"

    rm -f "$TMP"
  done
} < "$CSV"

echo "✅ Issues created from $CSV"

