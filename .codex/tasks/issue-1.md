# Codex Task Bootstrap
## Issue
https://github.com/thepapaswag/codex-cloud-workflow/issues/1
## Title
[Codex] Zero-click smoke test
## Body
## Objective
Smoke test codex-dispatch workflow

## Spec
- Label this issue `codex:ready`
- Observe draft PR + `@codex review`

## Branch
main

## Path allowlist
- docs/

## Validation
- run: echo "no validation"

---

## Codex Cloud Task Preamble

### Environment

### Setup
- git fetch -p && git checkout main && git pull --rebase origin main

### Tasks
- Summarize dispatch behaviour

### Artifacts
- `.codex/tasks/issue-<n>.md`
- PR comment confirming `@codex review`

## Notes
- Use the issue body as spec.
- Respect any path allowlist and branch hints.
