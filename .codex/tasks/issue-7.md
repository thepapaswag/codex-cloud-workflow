# Codex Task Bootstrap
## Issue
https://github.com/thepapaswag/codex-cloud-workflow/issues/7
## Title
[Codex] Reconfirm auto-PR + auto-summon
## Body
## Objective
Reconfirm auto-PR creation and auto-summon

## Spec
- Trigger the dispatch workflow; the job should create a draft PR and comment `@codex review` automatically.

## Branch
main

## Path allowlist
- docs/

## Validation
- run: echo "noop"

---

## Codex Cloud Task Preamble

### Environment
source .codex/cloud.env

### Setup
bash .codex/setup.sh

### Tasks
- No-op; this is a trigger validation

### Artifacts
- `.codex/tasks/issue-<n>.md`
- Draft PR created automatically and `@codex review` posted by the workflow

## Notes
- Use the issue body as spec.
- Respect any path allowlist and branch hints.
