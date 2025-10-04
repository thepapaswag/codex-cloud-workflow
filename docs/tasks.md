# Tasklist — Cloud Environment & Validation

Use this list to track remaining work now that Codex is connected and CPU-only cloud hooks are in place.

## Environment & Docs
- [x] Add `.codex/cloud.env` (CPU-only defaults)
- [x] Add `.codex/setup.sh` (dependency bootstrapper)
- [x] Document in `docs/cloud-environment.md`
- [x] Update Issue Form placeholders (source env + run setup)
- [x] Add environment hints to `AGENTS.md`

## Proof (Single Issue)
- [x] Create a minimal docs-only issue via the form
  - Environment: `source .codex/cloud.env`
  - Setup: `bash .codex/setup.sh`
- [x] Apply label `codex:ready` and confirm dispatch behavior
- [x] If PR is not auto-created, open PR from `codex/issue-<n>` → `main`
- [x] Comment `@codex review` on the PR
- [x] Verify Codex execution and artifacts/logs (PR #4 ack by Codex)
- [x] Merge PR (PR #4 merged)

## Batch (Multiple Issues)
- [ ] Prepare multi-row `codex_tasks.csv` and `.codex/preambles/*`
- [ ] Run `make batch` → issues created
- [ ] Follow the same PR/review flow as Proof

## CI & Guardrails
- [x] Confirm Spec Police behavior (allowlist + validation commands)
- [x] Adjust allowlist or commands as project needs (skip pytest if tests/ missing)

## Follow-ups
- [x] Decide whether to keep sample files (`.codex/preambles/*`, `codex_tasks.csv`) or move them under `examples/` (moved sample preamble)
- [ ] Consider adding per-stack examples (Torch/TensorFlow/JAX CPU) in project templates

## Auto-PR capability
- [x] Confirm org + repo settings allow Actions to create PRs
- [x] Re-test via new issue with codex:ready (PR #10 auto-created)
