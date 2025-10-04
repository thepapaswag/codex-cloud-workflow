#!/usr/bin/env bash
set -euo pipefail

# Creates or updates labels used by the workflow. Safe to re-run.
mk() { gh label create "$1" --color "$2" --description "$3" 2>/dev/null || gh label edit "$1" --color "$2" --description "$3"; }

mk "codex:ready"  "0E8A16" "Ready for Codex Cloud"
mk "automation"    "5319E7" "Automation-related"
mk "size:S"        "1D76DB" "Small task"
mk "size:M"        "FBCA04" "Medium task"
mk "size:L"        "B60205" "Large task"

echo "✅ Labels ensured (idempotent)."

