# Codex Task Bootstrap
## Issue
https://github.com/thepapaswag/codex-cloud-workflow/issues/3
## Title
[Codex] E2E test: CPU-only env hooks
## Body
## Objective
End-to-end test of Codex Cloud with CPU-only env and setup hooks

## Spec
- Add a short "Purpose" section near the top of docs/README.md clarifying this repo is a Codex bootstrap template.
- Only modify files under docs/.

## Branch
main

## Path allowlist
- docs/

## Validation
- run: echo "docs-only change"

---

## Codex Cloud Task Preamble

### Environment
source .codex/cloud.env

### Setup
bash .codex/setup.sh

### Tasks
- Edit docs/README.md to add the Purpose section (2–3 sentences)

### Artifacts
- Updated docs/README.md with the new Purpose section

## Notes
- Use the issue body as spec.
- Respect any path allowlist and branch hints.
