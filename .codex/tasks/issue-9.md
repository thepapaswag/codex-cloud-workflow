# Codex Task Bootstrap
## Issue
https://github.com/thepapaswag/codex-cloud-workflow/issues/9
## Title
[Codex] Hardened E2E revalidation
## Body
## Objective
Hardened workflow revalidation — auto PR + auto @codex summon

## Spec
- Trigger the dispatch workflow; it should create a draft PR and automatically post `@codex review`.

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
- No-op; only validate bridge + summon

### Artifacts
- `.codex/tasks/issue-<n>.md`
- Draft PR created automatically and `@codex review` posted by the workflow

## Notes
- Use the issue body as spec.
- Respect any path allowlist and branch hints.
