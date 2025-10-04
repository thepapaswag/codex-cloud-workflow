# Repo Bootstrap Quickstart (Codex Mini‑Project)

## Purpose
This repository is a lightweight bootstrap template for establishing a Codex‑friendly workflow in any project. It includes zero‑click Issue → draft PR bridging, guardrails (scope + validation), and a CPU‑only cloud environment layer so Codex Cloud can run reproducibly without relying on local GPUs. Clone or reuse this template in downstream repos where you want Codex Cloud to execute routine work.

This repo is wired for a zero‑click Codex flow: label an Issue `codex:ready` and a GitHub Action opens a draft PR and comments `@codex review`. Guardrails (allowlists, validation checks) and machine‑readable standards (`AGENTS.md`) are included.

## One‑Time Reminders (per repo)
1) Enable Issues (Settings → Features → Issues)
2) Ensure GitHub Actions token permissions match the workflows
3) Connect this repo to Codex Cloud so `@codex` on PRs works

## Quickstart
```bash
# Ensure skeleton + labels
make codex-bootstrap

# (Optional) Prove one task interactively
make proof

# Batch tasks: generate CSV + preambles, create Issues, auto‑summon Codex
make batch
```

## Cloud Environment (CPU-only)
- See `docs/cloud-environment.md` for details.
- In issues, include in the Preamble:
  - Environment: `source .codex/cloud.env`
  - Setup: `bash .codex/setup.sh`

## Files Added by the Bootstrap
- `.github/ISSUE_TEMPLATE/codex-task.yml` — machine‑readable issue form with Preamble
- `.github/workflows/codex-dispatch.yml` — Issue→draft PR bridge + `@codex review`
- `.github/workflows/spec-police.yml` — path allowlist + validation commands
- `.github/pull_request_template.md` — validation and scope checklist
- `scripts/codex/bootstrap_labels.sh` — idempotent labels
- `scripts/codex/batch_issues.sh` — CSV → Issues (supports `body_or_file` + preambles)
- `templates/issue_body.md` — issue body template for envsubst
- `AGENTS.md` — human + machine‑readable standards (YAML block)
- `Makefile` — `codex-bootstrap`, `labels`, `proof`, `batch`
 - `.codex/cloud.env` — CPU-only defaults
 - `.codex/setup.sh` — dependency bootstrapper
 - `docs/cloud-environment.md` — guidance and examples

## Notes
- CI commands in `spec-police.yml` are placeholders; tailor to your stack.
- Keep diffs small and pin the target branch in specs; Codex Cloud crawls the remote repo/branch.
- No secrets or environment‑specific credentials should be committed to this repo.
