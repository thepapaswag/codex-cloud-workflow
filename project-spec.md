# Codex Cloud + CLI Hybrid Workflow — Mini‑Project Spec (v0.1)

A tight, end‑to‑end package for running a **“Codex CLI → create GitHub issues → @codex in GitHub”** loop with a **Codex Proofing** stage, while keeping **Codex Cloud** perfectly in sync with your repo.

---

## 0) Goals & Outcomes

* **Move fast, safely:** Turn rough plans into high‑quality, atomic issues Codex can execute in the cloud.
* **Prove once, automate many:** Validate a representative task interactively (Proofing), then batch the rest.
* **Stay in sync:** Ensure Codex Cloud crawls the **right** branch and **fresh** state.
* **Guardrails by default:** Path allowlists, validation commands, PR templates, and CI checks.

**Deliverables** (created by this mini‑project):

* `AGENTS.md` wired to reusable standards vendored at `/codex/standards`.
* GitHub **Issue Form** for Codex tasks.
* Two GitHub Actions: **codex‑dispatch** (auto‑summon Codex) and **spec‑police** (scope/test enforcement).
* PR template with checklists.
* Script(s) to **preflight** and **batch‑create** issues from a CSV.

---

## 1) High‑Level Flow

```
(Proof once)      (Automate many)
┌─────────────┐   ┌────────────────────────────┐
│ codex (TUI) │→→ │ codex exec → CSV of tasks │
└─────┬───────┘   └────────────┬───────────────┘
      │                        │
      │(commit + push)         │ (review CSV)
      ▼                        ▼
  Create 1 issue           Batch create issues
  with perfect spec        (labels include codex:ready)
      │                        │
      ▼                        ▼
   @codex runs (cloud)   GitHub Action auto‑tags @codex
      │                        │
      ▼                        ▼
   Opens PR w/ tests      Codex PRs + CI checks
      │                        │
      └───review/merge──────────┘
```

---

## 2) Prereqs (one‑time)

* **Codex:** CLI for local proofing; Codex Cloud enabled & GitHub connected.
* **GitHub:** `gh` CLI installed; repo permissions to create issues, labels, and PRs.
* **CI:** GitHub Actions enabled; required checks (tests, lints) configured.

### 2A) Repo switches checklist (do once per repo)

* [ ] **Enable Issues** (*Settings → Features → Issues*).
* [ ] **Ensure Actions run** with the token permissions defined in the workflows (`permissions:` blocks grant `contents: write`, `pull-requests: write`, `issues: write`).
* [ ] **Connect the repo to Codex Cloud** so `@codex` on PRs works.

### 2B) Label bootstrapping (one‑liner)

Most straightforward path: create required labels via a bootstrap script.

**`scripts/codex/bootstrap_labels.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail
# Creates or updates labels used by the workflow. Safe to re-run.
mk() { gh label create "$1" --color "$2" --description "$3" 2>/dev/null || gh label edit "$1" --color "$2" --description "$3"; }
mk "codex:ready"  "0E8A16" "Ready for Codex Cloud"
mk "automation"    "5319E7" "Automation-related"
mk "size:S"        "1D76DB" "Small task"
mk "size:M"        "FBCA04" "Medium task"
mk "size:L"        "B60205" "Large task"
```

Run once per repo:

```bash
chmod +x scripts/codex/bootstrap_labels.sh
./scripts/codex/bootstrap_labels.sh
```

---

## 3) Keep Codex Cloud “In Sync” (Repo Hygiene)

Codex Cloud **crawls the remote repo/branch** it’s pointed at. To avoid drift:

* **Push early, push often** — small commits keep the crawl fresh.
* **Pin the branch in prompts** — e.g., “use `feature/docs‑sprint`”.
* **One purpose per branch** — avoid kitchen‑sink branches.
* **Smaller PRs** — improves Codex inference and your review speed.
* **Document entry points** — `docs/README.md` (or `CONTRIBUTING.md`) links to onboarding, architecture, troubleshooting.
* **Quarantine legacy** — move old content to `docs/historical/`.
* **Regenerate indexes after big moves** — re‑run any repo‑level indexing you rely on.
* **When sprinting:** `git push && codex ...` so cloud sees the latest.

> Tip (MVP agents + docs sprints): Before asking Codex to “capture progress in semantic memory,” commit the updated docs index and any **source‑of‑truth** files first.

---

## 4) Reusable Standards (Vendor‑in once)

Create a central repo `codex‑standards` that you **vendor** into each project at `/codex/standards`.

```bash
# In each project
git submodule add git@github.com:yourorg/codex-standards.git codex/standards
git commit -m "Add shared Codex standards"
```

**Project `AGENTS.md` (root, short index + project deltas):**

```md
# AGENTS.md

## Canonical standards
- Follow /codex/standards/conventions.md
- Follow /codex/standards/testing.md
- Follow /codex/standards/security.md

## Project-specific notes
- Preferred task runner: rye
- Integration test entrypoint: scripts/it.sh
- Codeowners: @eng-team, @qa

## How Codex should work here
- Pin work to the prompt’s `branch:`. Use the provided path allowlist.
- Run unit tests and lints before proposing patches.
- Keep diffs small; separate refactors from feature changes.
```

> Optional: Also expose the same standards via a **read‑only MCP server** and mention it in `AGENTS.md`. The repo copy remains the source of truth for Cloud/GitHub.

### 4A) AGENTS.md Template with Machine‑Readable Standards (YAML)

Use this template to keep standards concise for humans and parseable by tools (Codex, CI, scripts).

````md
# AGENTS.md

This repository follows our shared standards vendored at `/codex/standards/*`.
- Conventions: `/codex/standards/conventions.md`
- Testing: `/codex/standards/testing.md`
- Security: `/codex/standards/security.md`

**Working with Codex**
- Pin the branch you want Codex Cloud to use in specs and issues.
- Keep tasks small; separate refactors from features; keep diffs minimal.
- Update docs and tests with every change; move legacy to `docs/historical/`.

```yaml
codex:
  branch_hint: main
  path_allowlist:
    - api/
    - docs/
  pr_limits:
    max_changed_lines: 300
    separate_refactor_prs: true
  validation:
    ci_checks: ["pytest", "docs"]
    must_update_docs: true
    must_update_tests: true
  git_policy:
    small_commits: true
    push_often: true
    forbid_kitchen_sink_branches: true
  debt_policy:
    clean_dead_code_immediately: true
    maintain_directory_hygiene: true
    todo_policy: issue_only
  commit_conventions:
    style: conventional_commits
    require_issue_link: true
  branching:
    model: trunk
    feature_branch_prefix: "feature/"
    codex_branch_prefix: "codex/"
  testing:
    min_coverage: 80
  linting:
    python: ["ruff", "black", "mypy"]
    node: ["eslint", "prettier"]
    go: ["gofmt", "govet"]
  security:
    forbid_secrets_in_repo: true
    dependency_update_frequency: "weekly"
  pr_policy:
    require_issue_reference: true
    require_checklist: true
  adr:
    enable: true
    dir: "docs/adr"
  release:
    semver: true
    tag_prefix: "v"
  docs:
    entry_points:
      - docs/README.md
      - CONTRIBUTING.md
    archive_dir: docs/historical/
````

**Project‑specific notes**

* Preferred task runner: `rye`
* Integration test entrypoint: `scripts/it.sh`
* Codeowners: `@eng-team`, `@qa`

````

---

## 5) Codex Proofing (Do this once per project / per pattern)
Purpose: prove the workflow on **one representative task** before batching.

**Checklist**
1. **Create a short, atomic candidate** (e.g., update `AGENT.md` header + fix broken links).
2. **Run interactively**: `codex` (TUI). Prompt: _“On branch `feature/docs‑sprint`, update `AGENT.md` header, fix dead links, and add a 6‑step onboarding checklist. Only touch `docs/`.”_
3. **Review diffs** carefully; require tests/docs build to pass locally.
4. **Commit + push** the result to the feature branch.
5. **Open a single GitHub issue** (using the Issue Form below) that captures the finalized spec. Label it `codex:ready`.
6. **Summon Codex in GitHub** by comment (or let the Action do it automatically). Confirm a good PR arrives.
7. **Merge** the PR. You’re now ready to **batch**.

---

## 6) Issue Form (machine‑readable mini‑spec)
Create `.github/ISSUE_TEMPLATE/codex-task.yml`:
```yaml
name: Codex Task
description: Structured task for Codex Cloud
title: "[Codex] <short title>"
labels: ["codex:ready","automation"]
body:
  - type: input
    id: objective
    attributes: { label: Objective, description: One sentence outcome }
    validations: { required: true }
  - type: textarea
    id: spec
    attributes:
      label: Light Spec
      description: Steps / constraints / files to touch
      value: |
        ## Context
        - repo: <name>
        - branch: <branch>
        - path-allowlist:
          - api/
          - docs/
        ## Steps
        1) ...
        2) ...
        ## Acceptance
        - [ ] unit tests updated
        - [ ] docs updated
  - type: dropdown
    id: size
    attributes: { label: Size, options: ["S","M","L"] }
  - type: textarea
    id: tests
    attributes:
      label: Commands to Validate
      value: |
        - run: pytest -q
        - run: make docs
  - type: input
    id: branch
    attributes: { label: Target branch, placeholder: feature/docs-sprint }

  # --- Codex Cloud Task Preamble (optional, but recommended) ---
  - type: textarea
    id: preamble_env
    attributes:
      label: Codex Cloud Task Preamble — Environment
      description: Env vars, runner flags, or tool versions required
      placeholder: |
        export VECTOR_MACHINE_FORCE_CPU=true
        export CUDA_VISIBLE_DEVICES=""
  - type: textarea
    id: preamble_setup
    attributes:
      label: Codex Cloud Task Preamble — Setup
      description: One-time fetch/branch, create working branch, install deps
      placeholder: |
        git fetch -p && git checkout main && git pull --rebase origin main
        git checkout -b codex/<short-branch>
  - type: textarea
    id: preamble_tasks
    attributes:
      label: Codex Cloud Task Preamble — Tasks
      description: Bullet list of concrete steps Codex should follow
      placeholder: |
        - Inventory why test X is skipped
        - Provide CPU-only alternative for Y
        - Remove skip guard and run unit gate
  - type: textarea
    id: preamble_artifacts
    attributes:
      label: Codex Cloud Task Preamble — Artifacts
      description: Files, logs, or docs Codex should produce
      placeholder: |
        - Updated tests/<path>/conftest.py
        - Proof of passing test run
        - Docs updates if applicable
````

---

## 7) Auto‑Summon Codex on “Ready” Issues (zero‑click bridge)

When an issue gets `codex:ready`, open a **draft PR** that references the issue, seed it with a small sentinel commit, and then comment **`@codex review`** on that PR. This aligns with Codex’s documented PR trigger and gives Codex a branch to push to.

**`.github/workflows/codex-dispatch.yml`**

```yaml
name: Dispatch Codex on Ready
on:
  issues:
    types: [labeled, opened, edited]
permissions:
  contents: write
  pull-requests: write
  issues: write
jobs:
  open-draft-pr-and-summon:
    if: contains(github.event.issue.labels.*.name, 'codex:ready')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - name: Prepare branch and sentinel commit
        env:
          ISSUE_NUM: ${{ github.event.issue.number }}
          ISSUE_TITLE: ${{ github.event.issue.title }}
          ISSUE_BODY: ${{ github.event.issue.body }}
          REPO: ${{ github.repository }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          BASE_BRANCH: ${{ github.event.repository.default_branch }}
        run: |
          set -euo pipefail
          BRANCH="codex/issue-${ISSUE_NUM}"
          git config user.name "github-actions[bot]"
          git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
          git checkout -B "$BRANCH" "origin/${BASE_BRANCH}"
          mkdir -p .codex/tasks
          cat > ".codex/tasks/issue-${ISSUE_NUM}.md" <<'EOF'
          # Codex Task Bootstrap
          ## Issue
          ${{ github.event.issue.html_url }}
          ## Title
          ${{ github.event.issue.title }}
          ## Body
          ${{ github.event.issue.body }}
          ## Notes
          - Use the issue body as spec.
          - Respect any path allowlist and branch hints.
          EOF
          git add .codex/tasks/issue-${ISSUE_NUM}.md
          git commit -m "chore: codex bootstrap for issue #${ISSUE_NUM}"
          git push --set-upstream origin "$BRANCH"
          PR_URL=$(gh pr create \
            --repo "$REPO" \
            --base "${BASE_BRANCH}" \
            --head "$BRANCH" \
            --draft \
            --title "Codex: Issue #${ISSUE_NUM} — ${ISSUE_TITLE}" \
            --body $'Closes #${ISSUE_NUM}

Bootstrap PR for Codex Cloud. See `.codex/tasks/issue-'"${ISSUE_NUM}"'.md` for the spec snapshot.' \
            --json url --jq .url)
          echo "PR_URL=$PR_URL" >> "$GITHUB_ENV"
      - name: Summon Codex on the PR
        env:
          PR_URL: ${{ env.PR_URL }}
        run: |
          gh pr comment "$PR_URL" --body "@codex review"
```

> The draft PR supplies a minimal change (`.codex/tasks/issue-<n>.md`) so the PR exists. Codex can then push commits to the branch or open a follow‑up PR.

---

## 8) PR Template + “Spec Police” CI

**PR template** (`.github/pull_request_template.md`):

```md
### What changed
- …

### Validation
- [ ] `pytest -q` passes
- [ ] Docs updated (`docs/`)

### Scope control
- [ ] Only paths in allowlist were modified
- [ ] Diff under 300 lines (or rationale provided)
```

**Scope & tests enforcement** (`.github/workflows/spec-police.yml`):

```yaml
name: Spec Police
on:
  pull_request:
    types: [opened, synchronize]
permissions:
  contents: read
  pull-requests: write
jobs:
  scope-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with: { fetch-depth: 0 }
      - name: Enforce path allowlist (example: api/ and docs/)
        run: |
          ALLOWLIST_REGEX="^(api/|docs/)"
          CHANGED=$(git diff --name-only origin/${{ github.base_ref }})
          echo "$CHANGED" | grep -vE "$ALLOWLIST_REGEX" && {
            echo "Touched files outside allowlist"; exit 1; } || true
      - name: Run validation commands
        run: |
          pytest -q
          make -s docs
```

---

## 9) Batch Creation from Codex CLI (after Proofing)

**Preflight (generate tasks CSV)**

* From the project root:

```bash
codex exec --prompt "Scan ./services and ./docs for TODOs and pending refactors. Write a CSV named codex_tasks.csv with columns: title,size,branch,allowlist,tests,body. Keep tasks atomic; prefer S/M size."
```

* Inspect/trim `codex_tasks.csv`.

**Issue body template** (`templates/issue_body.md`):

```md
## Objective
${OBJECTIVE}

## Spec
${SPEC}

## Branch
${BRANCH}

## Path allowlist
${ALLOWLIST}

## Validation
${TESTS}

---

## Codex Cloud Task Preamble

### Environment
${PREAMBLE_ENV}

### Setup
${PREAMBLE_SETUP}

### Tasks
${PREAMBLE_TASKS}

### Artifacts
${PREAMBLE_ARTIFACTS}
```

md

## Objective

${OBJECTIVE}

## Spec

${SPEC}

## Branch

${BRANCH}

## Path allowlist

${ALLOWLIST}

## Validation

${TESTS}

````

**Batch issues script** (`scripts/codex/batch_issues.sh`):
```bash
#!/usr/bin/env bash
set -euo pipefail
CSV=${1:-codex_tasks.csv}
TEMPLATE=${2:-templates/issue_body.md}
LABELS=${LABELS:-"codex:ready,automation"}

# CSV schema (minimal): title,size,branch,allowlist,tests,body_or_file[,preamble_env,preamble_setup,preamble_tasks,preamble_artifacts]
# Notes:
# - If column 6 points to a readable file path, its contents become the body/spec; otherwise it is treated as literal text.
# - Preamble columns are optional; if present they are injected into the template placeholders.

# shellcheck disable=SC2162
{
  read header # skip header
  while IFS=, read TITLE SIZE BRANCH ALLOWLIST TESTS BODY_OR_FILE PRE_ENV PRE_SETUP PRE_TASKS PRE_ARTIFACTS; do
    [ -n "${TITLE:-}" ] || continue

    if [ -f "$BODY_OR_FILE" ]; then
      BODY=$(cat "$BODY_OR_FILE")
    else
      BODY="$BODY_OR_FILE"
    fi

    export OBJECTIVE="$TITLE"
    export SPEC="$BODY"
    export BRANCH="$BRANCH"
    export ALLOWLIST="$ALLOWLIST"
    export TESTS="$TESTS"
    export PREAMBLE_ENV="${PRE_ENV:-}"
    export PREAMBLE_SETUP="${PRE_SETUP:-}"
    export PREAMBLE_TASKS="${PRE_TASKS:-}"
    export PREAMBLE_ARTIFACTS="${PRE_ARTIFACTS:-}"

    BODY_TXT=$(envsubst < "$TEMPLATE")

    gh issue create \
      --title "[Codex] $TITLE" \
      --label "$LABELS,size:$SIZE" \
      --body "$BODY_TXT"
  done
} < "$CSV"
````

bash
#!/usr/bin/env bash
set -euo pipefail
CSV=${1:-codex_tasks.csv}
TEMPLATE=${2:-templates/issue_body.md}
LABELS=${LABELS:-"codex:ready,automation"}

# Skip header, read CSV columns: title,size,branch,allowlist,tests,body

tail -n +2 "$CSV" | while IFS=',' read -r TITLE SIZE BRANCH ALLOWLIST TESTS BODY; do
export OBJECTIVE="$TITLE"
export SPEC="$BODY"
export BRANCH="$BRANCH"
export ALLOWLIST="$ALLOWLIST"
export TESTS="$TESTS"

BODY_TXT=$(envsubst < "$TEMPLATE")
gh issue create 
--title "[Codex] $TITLE" 
--label "$LABELS,size:$SIZE" 
--body "$BODY_TXT"
done

```

> Add simple **chunking** rules (optional): split any task estimated >N files or >M LOC into multiple issues before creating.

---

## 10) Daily Usage (quick)
1. **Proofing already done?** If not, do §5 once.
2. **Cut a branch** for the sprint (e.g., `feature/docs‑sprint`).
3. **`codex exec` → CSV** of atomic tasks; review/edit CSV.
4. **Run** `scripts/codex/batch_issues.sh` → labeled issues.
5. **Action auto‑summons `@codex`** → Codex Cloud works; PRs land.
6. **CI (“Spec Police”)** enforces scope + tests; you review/merge.

---

## 11) Multi‑Repo Fan‑Out (optional)
- Keep one **parent tracker issue** with a checklist of child issues (one per repo).
- Generate repo‑specific CSVs (with per‑repo allowlists) and run the batch script per repo.
- Use a small Action to post back progress to the parent when PRs merge.

---

## 12) Telemetry & Traceability (optional)
Inject a standard header into Codex‑summon comments (or in issue bodies) so runs are traceable:
```

<!-- codex-run:
origin=gh-issue
issue=#1234
repo=acme/api
size=S
validation="pytest -q"
-->

```
Export to logs or a sheet to see failure patterns and tune specs.

---

## 13) Safety & Permissions
- **Branch protections:** require PR reviews and CI green before merge.
- **Least privilege:** `GITHUB_TOKEN` with minimal scopes; no auto‑merge.
- **Internet access (Cloud):** keep default off, enable narrowly if needed.
- **Audit trail:** enforce conventional commit messages and link issues ⇄ PRs.

---

## 14) Troubleshooting Quick Hits
- **Codex didn’t see my changes?** You didn’t push. Push and re‑trigger.
- **Wrong branch used?** Pin `branch:` in the issue and in your prompts.
- **PR touches unexpected paths?** Tighten the allowlist; CI will block.
- **Long diffs?** Split into S/M tasks; avoid L unless unavoidable.
- **Missing deps in Cloud?** Add setup steps/env notes in the issue spec.

---

## 15) Repo Skeleton (what this mini‑project adds)
```

.github/
ISSUE_TEMPLATE/
codex-task.yml
workflows/
codex-dispatch.yml
spec-police.yml
pull_request_template.md
codex/
standards/                # submodule or subtree
scripts/
codex/
batch_issues.sh
bootstrap_labels.sh
templates/
issue_body.md
AGENTS.md
Makefile                    # or Justfile (optional)
docs/
README.md
historical/

```
.github/
  ISSUE_TEMPLATE/
    codex-task.yml
  workflows/
    codex-dispatch.yml
    spec-police.yml
  pull_request_template.md
codex/
  standards/                # submodule or subtree
scripts/
  codex/
    batch_issues.sh
    bootstrap_labels.sh
templates/
  issue_body.md
AGENTS.md
docs/
  README.md
  historical/
```

.github/
ISSUE_TEMPLATE/
codex-task.yml
workflows/
codex-dispatch.yml
spec-police.yml
pull_request_template.md
codex/
standards/                # submodule or subtree
scripts/
codex/
batch_issues.sh
templates/
issue_body.md
AGENTS.md
docs/
README.md
historical/

````

---

## 16) Quickstart Commands
```bash
# 1) Vendor standards and add AGENTS.md
git submodule add git@github.com:yourorg/codex-standards.git codex/standards
cp codex/standards/AGENTS.template.md ./AGENTS.md

# 2) Add templates & workflows
mkdir -p .github/ISSUE_TEMPLATE .github/workflows scripts/codex templates docs/historical
# (paste the files from this spec)

git add . && git commit -m "codex: bootstrap standards, issue form, actions, scripts"

# 3) Create labels (safe to re-run)
chmod +x scripts/codex/bootstrap_labels.sh
./scripts/codex/bootstrap_labels.sh

# 4) Proof one task interactively
codex  # run TUI, validate a small docs change on a feature branch, commit + push

# 5) Batch the rest
codex exec --prompt "Write codex_tasks.csv with atomic tasks for the docs sprint…"
./scripts/codex/batch_issues.sh codex_tasks.csv
# Action opens a draft PR per issue and comments @codex review → PRs → review/merge

# ——— Make/Just quick path ———
# Using Make
make codex-bootstrap
make proof     # optional
make batch

# Or using just
just codex-bootstrap
just proof     # optional
just batch
````

---

**You now have a compact, reproducible workflow that unifies Codex CLI proofing, cloud execution via GitHub, and repo hygiene to keep Codex perfectly aligned with your source of truth.**

## 17) Feasibility & Codex CLI Execution Plan

**Feasible?** Yes. Everything here uses standard GitHub Free features (Issues, Issue Forms, Actions, PR templates) and Codex Cloud’s PR comment trigger. The only out‑of‑repo steps are in **§2A Repo switches checklist**.

**How Codex CLI + you implement this spec**

* **Interactive (Proofing)**: Use `codex` TUI to generate/edit the YAML workflows, issue form, PR template, and scripts. Review diffs, approve, commit, and push. Small, atomic changes fit Proofing best.
* **Scripted (Batching)**: Use `codex exec` to: (a) generate `codex_tasks.csv` from TODOs/refactors; (b) optionally scaffold file skeletons you haven’t added yet (Codex will propose content; you approve via PRs).
* **Zero‑click from Issues**: As soon as issues are labeled `codex:ready`, the **Dispatch** workflow opens a **draft PR** and posts `@codex review`. No manual steps.

**Remember** (once per repo):

* [ ] Enable **Issues**.
* [ ] Ensure **Actions** run with the token permissions in the workflow.
* [ ] Connect the repo to **Codex Cloud** so `@codex` on PRs works.

**Notes**

* For private repos on the Free plan, watch Actions minutes; public repos and self‑hosted runners are unlimited.
* If your org restricts token defaults, the `permissions:` blocks in the sample YAML grant only the writes required by this workflow.

---

**You now have a compact, reproducible workflow that unifies Codex CLI proofing, a zero‑click Issues → PR bridge, cloud execution via GitHub, and repo hygiene to keep Codex perfectly aligned with your source of truth.**

## 18) Makefile / Justfile (Muscle‑memory commands)

Use one of these to standardize the flow.

**Makefile**

```make
# ---------- Config ----------
CSV ?= codex_tasks.csv
ISSUE_TEMPLATE ?= templates/issue_body.md
LABEL_BOOTSTRAP := scripts/codex/bootstrap_labels.sh
BATCH_ISSUES    := scripts/codex/batch_issues.sh

# ---------- Guards ----------
define need
	@command -v $(1) >/dev/null 2>&1 || \
	{ echo "Missing dependency: $(1)"; exit 1; }
endef

# ---------- Targets ----------
.PHONY: codex-bootstrap labels batch proof check

check:
	$(call need,gh)
	$(call need,codex)

labels: check
	chmod +x $(LABEL_BOOTSTRAP)
	./$(LABEL_BOOTSTRAP)

codex-bootstrap: check
	@mkdir -p .github/ISSUE_TEMPLATE .github/workflows scripts/codex templates docs/historical
	@echo "✅ Skeleton ensured."
	@echo "🔔 One-time reminders:"
	@echo "   1) Enable Issues (Settings → Features → Issues)"
	@echo "   2) Ensure Actions token permissions match your workflows"
	@echo "   3) Connect this repo to Codex Cloud so @codex on PRs works"
	$(MAKE) labels

# Generate CSV of tasks, then create issues -> workflow opens draft PRs + '@codex review'
batch: check
    # Ask Codex to (1) write a CSV and (2) author preamble files per task.
    codex exec --prompt "Scan ./ for atomic tasks and: (a) write {{CSV}} with columns: title,size,branch,allowlist,tests,body_or_file,preamble_env,preamble_setup,preamble_tasks,preamble_artifacts; (b) for each task, write a markdown preamble at .codex/preambles/<slug>.md including sections: Environment, Setup, Tasks, Artifacts, Acceptance Criteria; (c) set body_or_file to that preamble file path for each row. Prefer S/M tasks."
    chmod +x scripts/codex/batch_issues.sh
    ./scripts/codex/batch_issues.sh {{CSV}} {{ISSUE_TEMPLATE}}
    echo "🧩 Issues created with preambles. Workflow will open draft PRs and summon @codex."

proof:
    codex
```

---

## 19) Re‑review Summary (completeness & accuracy)

* **End‑to‑end flow is covered**: proofing (interactive), batching (CLI), labels, issue form, zero‑click Issue→draft‑PR+`@codex review`, PR template, scope/tests enforcement, and daily ops.
* **Cloud context alignment**: repo hygiene (§3) ensures Codex Cloud crawls the right, fresh branch; prompts/issue form include branch hints and allowlists.
* **Self‑containment**: everything is repo‑local and runs on GitHub Free. Only external steps are the three toggles in §2A (Issues, Actions token perms, connect to Codex Cloud).
* **CLI compatibility**: `codex` (proof) and `codex exec` (batch) are first‑class; Make/Just targets simplify execution.
* **Safety**: branch protections + CI gate merges; workflows request minimal write perms.

You can now copy this spec into a fresh repo, run `make codex-bootstrap`, prove one task with `make proof`, then `make batch` to fan out tasks. The Dispatch workflow takes it from there automatically.

