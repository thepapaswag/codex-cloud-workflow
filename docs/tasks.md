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
- [ ] Verify Codex execution and artifacts/logs (in progress)
- [ ] Merge PR

## Batch (Multiple Issues)
- [ ] Prepare multi-row `codex_tasks.csv` and `.codex/preambles/*`
- [ ] Run `make batch` → issues created
- [ ] Follow the same PR/review flow as Proof

## CI & Guardrails
- [ ] Confirm Spec Police behavior (allowlist + validation commands)
- [ ] Adjust allowlist or commands as project needs

## Follow-ups
- [ ] Decide whether to keep sample files (`.codex/preambles/*`, `codex_tasks.csv`) or move them under `examples/`
- [ ] Consider adding per-stack examples (Torch/TensorFlow/JAX CPU) in project templates
