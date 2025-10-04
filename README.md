# Codex Cloud Workflow Template

This repository is a bootstrap template for wiring Codex CLI + Codex Cloud into any project. It packages a zero-click “issue → draft PR → @codex review” bridge, CPU-only cloud environment hooks, reusable standards, and automation guardrails so you can copy or fork it into other repos and start running Codex safely.

## What’s Included
- **Dispatch workflow** (`.github/workflows/codex-dispatch.yml`): when an issue is labeled `codex:ready`, a branch is prepared with a sentinel task spec, a draft PR is opened, and `@codex review` is posted automatically.
- **Spec Police workflow** (`.github/workflows/spec-police.yml`): enforces path allowlists and runs validation commands (skips `pytest` if tests aren’t present; always runs `make -s docs`).
- **Issue form & templates**: `.github/ISSUE_TEMPLATE/codex-task.yml`, PR template, and `templates/issue_body.md` keep specs machine-readable for Codex.
- **CPU-only Cloud environment**: `.codex/cloud.env` and `.codex/setup.sh` disable GPUs and install dependencies using language package managers only (pip/npm/go). See `docs/cloud-environment.md`.
- **Reusable standards**: `AGENTS.md` references shared conventions (vendor under `codex/standards/`) and encodes machine-readable policies.
- **Scripts & Make targets**: `scripts/codex/bootstrap_labels.sh`, `scripts/codex/batch_issues.sh`, and `Makefile` commands (`codex-bootstrap`, `labels`, `proof`, `batch`).
- **Documentation set**:
  - `docs/README.md` – quickstart and reminders
  - `docs/cloud-environment.md` – CPU-only environment guidance
  - `docs/codex-implementation-plan.md` – plan + validation checklist
  - `docs/tasks.md` – current status/tasklist
  - `project-spec.md` – original spec source
- **Examples**: sample preamble and CSV under `examples/` for reference when generating batch issues.

## Quickstart
1. **Clone or fork this template** into a new repo.
2. **Run one-time setup** (labels, skeleton) locally:
   ```bash
   make codex-bootstrap
   ```
3. **Proof one task interactively** (Codex CLI) if desired:
   ```bash
   make proof
   ```
4. **Batch tasks** via Codex CLI:
   ```bash
   make batch
   ```
   - Codex CLI will generate `codex_tasks.csv` style input (see `examples/`).
   - `scripts/codex/batch_issues.sh` creates issues with preambles.
5. **Zero-click bridge** kicks in:
   - Issues labeled `codex:ready` → draft PR + `@codex review`.
   - Workflow posts instructions if org policy blocks PR creation.

## CPU-Only Cloud Environment
Codex Cloud runners remain CPU-only even if local development uses GPUs. All tasks should source `.codex/cloud.env` and run `.codex/setup.sh` in their issue preamble. Customize `requirements-cloud.txt` (if needed) to swap GPU packages for CPU variants in downstream projects. Details: `docs/cloud-environment.md`.

## Guardrails & Best Practices
- Keep issues scoped to allowlisted paths to avoid Spec Police failures.
- Update `AGENTS.md` with project-specific notes but retain the machine-readable YAML.
- Adjust `Spec Police` commands when you introduce real test/documentation jobs.
- If GitHub Actions is restricted from creating PRs, the workflow comments instructions instead; enable “Allow GitHub Actions to create and approve pull requests” to use zero-click PRs.

## Repository Layout (excerpt)
```
.
├── .github/
│   ├── ISSUE_TEMPLATE/codex-task.yml
│   ├── pull_request_template.md
│   └── workflows/
├── .codex/
│   ├── cloud.env
│   └── setup.sh
├── AGENTS.md
├── docs/
│   ├── README.md
│   ├── cloud-environment.md
│   ├── codex-implementation-plan.md
│   └── tasks.md
├── examples/
│   ├── codex_tasks.sample.csv
│   └── preambles/sample-docs-task.md
└── scripts/
    └── codex/
        ├── batch_issues.sh
        └── bootstrap_labels.sh
```

## Validation Status
- Full proof PR merged (PR #4) with Codex review acknowledgement.
- Auto-PR creation and auto-summon confirmed after workflow hardening (PR #10).
- Outstanding work (see `docs/tasks.md`): batch-flow validation, optional examples cleanup, per-stack sample guidance.

## Using This Template in Other Repos
1. Copy or fork the repository into your target project.
2. Update `AGENTS.md` with project-specific notes, allowlists, and conventions.
3. Adjust the path allowlist and validation commands in `Spec Police` to match the project.
4. Vend shared standards into `codex/standards/` (submodule or subtree).
5. Run through the validation checklist in `docs/codex-implementation-plan.md` once per new project.

## Contributing
Improvements to this template (examples, documentation, additional guardrails) are tracked in `docs/tasks.md`. Feel free to open issues or PRs when you discover repeatable patterns that should ship with the bootstrap.
