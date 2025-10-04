# Codex Implementation Plan — Repo Bootstrap via Spec

Status legend: [ ] pending · [~] in progress · [x] done

Primary objective: Stand up the full mini‑project workflow so that a labeled Issue (`codex:ready`) automatically opens a draft PR and summons `@codex review`, with guardrails and machine‑readable standards in place, and batching enabled via Make/Just and scripts.

Usage note: This repository acts as a bootstrap template; routine Codex Cloud work will happen in downstream projects cloned from here. Proofing/batch phases remain for validation, not day‑to‑day operations.

---

## Phase 0 — Preflight
- [ ] Create working branch `codex/bootstrap`.
- [ ] Verify `gh` CLI is installed and authenticated.
- [ ] Confirm GitHub Actions is enabled for the repo.
- [ ] Ensure Issues are enabled (Settings → Features → Issues).

Deliverables check: none (environment only)

---

## Phase 1 — Repository Scaffold (files & structure)
- [x] Create directories:
  - `.github/ISSUE_TEMPLATE/`
  - `.github/workflows/`
  - `scripts/codex/`
  - `templates/`
  - `docs/historical/`
  - `codex/standards/` (placeholder or submodule path)
- [x] Add files:
  - [x] `.github/ISSUE_TEMPLATE/codex-task.yml`
  - [x] `.github/workflows/codex-dispatch.yml`
  - [x] `.github/workflows/spec-police.yml`
  - [x] `.github/pull_request_template.md`
  - [x] `scripts/codex/bootstrap_labels.sh` (idempotent)
  - [x] `scripts/codex/batch_issues.sh` (CSV with `body_or_file` + preamble columns)
  - [x] `templates/issue_body.md`
  - [x] `AGENTS.md` (with machine‑readable YAML block)
  - [x] One of: `Makefile` or `Justfile` (include Makefile if unsure)
  - [x] `docs/README.md` (quickstart + one‑time reminders)

Acceptance mapping:
- Structure matches spec skeleton (DoD: Structural)

---

## Phase 2 — Standards & AGENTS (governance)
- [x] Vendor or placeholder for `codex/standards/`.
- [x] Author `AGENTS.md` including YAML keys:
  - `branch_hint`, `path_allowlist`, `pr_limits`, `validation`, `git_policy`, `debt_policy`, `commit_conventions`, `branching`, `testing`, `linting`, `security`, `pr_policy`, `adr`, `release`, `docs.entry_points`, `docs.archive_dir`.

Acceptance mapping:
- `AGENTS.md` YAML parses cleanly (DoD: Structural)

---

## Phase 3 — Issue Form & Templates
- [x] Write `.github/ISSUE_TEMPLATE/codex-task.yml` with fields:
  - Objective, Light Spec, Size (S/M/L), Commands to Validate, Target branch
  - Codex Cloud Task Preamble: Environment, Setup, Tasks, Artifacts
- [x] Write `templates/issue_body.md` to render Objective/Spec/Allowlist/Validation + Preamble sections.

Acceptance mapping:
- Issue form contains Preamble fields; template renders Preamble (DoD: Structural)

---

## Phase 4 — Workflows (Zero‑Click bridge + CI guardrails)
- [x] Implement `.github/workflows/codex-dispatch.yml`:
  - Triggers on Issues labeled `codex:ready`.
  - Creates branch `codex/issue-<n>` from default branch.
  - Writes sentinel `.codex/tasks/issue-<n>.md` including URL, title, and body snapshot.
  - Opens draft PR titled `Codex: Issue #<n> — <title>` with body `Closes #<n>` and pointer to sentinel.
  - Comments `@codex review` on the PR.
  - Permissions: `contents: write`, `pull-requests: write`, `issues: write`.
- [x] Implement `.github/workflows/spec-police.yml`:
  - Enforce path allowlist via regex (e.g., `^(api/|docs/)`).
  - Run validation commands (e.g., `pytest -q`, `make -s docs`).

Acceptance mapping:
- Dispatch opens draft PR and comments `@codex review` (DoD: Automation & Workflows)
- Spec‑police runs on PR events (DoD: Automation & Workflows)

---

## Phase 5 — Scripts & Batching Flow
- [x] `scripts/codex/bootstrap_labels.sh`:
  - Creates/updates labels: `codex:ready`, `automation`, `size:S`, `size:M`, `size:L`.
  - Safe to re‑run; exit non‑zero on unexpected failures.
- [x] `scripts/codex/batch_issues.sh`:
  - CSV schema: `title,size,branch,allowlist,tests,body_or_file,preamble_env,preamble_setup,preamble_tasks,preamble_artifacts`.
  - If `body_or_file` is a path, ingest file contents; else treat as literal.
  - Use `envsubst` to fill `templates/issue_body.md` and `gh issue create` with labels `codex:ready,automation,size:<S|M|L>`.
- [x] Makefile targets:
  - `check`: verify `gh` and `codex`.
  - `labels`: run bootstrap script.
  - `codex-bootstrap`: ensure skeleton + one‑time reminders.
  - `batch`: run `codex exec` to generate CSV and preamble files, then run batch script.
  - `proof`: run `codex` (TUI) for interactive proofing.

Acceptance mapping:
- Scripts executable and functional; Make targets exist (DoD: Scripts & Commands)

---

## Phase 6 — Documentation & Quickstart
- [x] `docs/README.md` includes Quickstart and reminders:
  1) Enable Issues (if off)
  2) Ensure Actions token permissions match workflows
  3) Connect repo to Codex Cloud so `@codex` on PRs works
- [x] Explain `make codex-bootstrap`, `make labels`, `make proof`, `make batch`.

Acceptance mapping:
- README contains required reminders (DoD: Safety & Public Readiness)

---

## Phase 7 — Proofing (recommended)
- [ ] Create a tiny Issue via the form; label `codex:ready`.
- [ ] Observe Dispatch → branch + draft PR + `@codex review` comment.
- [ ] Tune allowlist regex if bootstrap files cause noise.

Acceptance mapping:
- Manual test demonstrates bridge behavior (DoD: Automation & Workflows)

---

## Phase 8 — Batch Ready
- [ ] Run `make batch` to generate a sample `codex_tasks.csv` + `.codex/preambles/<slug>.md`.
- [ ] Create a few Issues from CSV; verify body includes Preamble.
- [ ] Confirm dispatch opens draft PRs for created Issues.

Acceptance mapping:
- Issues render preamble; workflows trigger as expected (DoD: Zero‑Click & Preamble Behavior)

---

## Phase 9 — Hardening & Safety
- [ ] Confirm no secrets or env‑specific credentials are in repo.
- [ ] Verify workflow permissions are minimal.
- [ ] Note that CI commands may fail in a fresh repo; call out placeholders in `docs/README.md`.

Acceptance mapping:
- Public‑safe posture documented (DoD: Safety & Public Readiness)

---

## Phase 10 — Handoff
- [ ] Open a draft PR titled `codex: bootstrap spec` with a concise changelog.
- [ ] Summarize next steps in PR description (labels script, §2A toggles, start Proof/Batch).
- [ ] Merge after review.

Acceptance mapping:
- Handoff notes present; merge readiness clear (General)

---

## Cross‑Reference: Objectives → Plan Phases
1) Scaffold repo → Phases 1–2
2) Zero‑click bridge → Phase 4, Phase 7
3) Governance & guardrails → Phases 2, 4
4) Prepare batching → Phase 5, Phase 8
5) Codify standards → Phase 2
6) Public‑safe → Phases 6, 9

## Cross‑Reference: Acceptance Criteria → Verification Points
- Structural → Phases 1–3
- Automation & Workflows → Phase 4, Phase 7
- Scripts & Commands → Phase 5
- Zero‑Click & Preamble Behavior → Phase 8
- Safety & Public Readiness → Phase 6, Phase 9

---

## Notes & Constraints
- No org‑level changes (branch protections, billing, SSO) performed by automation.
- Assume GitHub Free; Actions minutes limited on private repos.
- Push early and pin branch in prompts; Codex Cloud crawls remote.
- Keep diffs small; follow conventional commits; respect allowlists.
