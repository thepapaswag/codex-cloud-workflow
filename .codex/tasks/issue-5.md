# Codex Task Bootstrap
## Issue
https://github.com/thepapaswag/codex-cloud-workflow/issues/5
## Title
[Codex] Auto-PR capability test
## Body
## Objective
Auto-PR capability test

## Spec
- Make no changes; just validate that Dispatch can create a draft PR automatically now.

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
- Draft PR opened automatically and @codex review comment posted

## Notes
- Use the issue body as spec.
- Respect any path allowlist and branch hints.
