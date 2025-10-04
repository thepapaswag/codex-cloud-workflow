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
.PHONY: codex-bootstrap labels batch proof check docs

check:
	$(call need,gh)
	@echo "✅ gh CLI present"
	@# Optional: check codex CLI if installed locally
	@command -v codex >/dev/null 2>&1 && echo "✅ codex CLI present" || echo "ℹ️ codex CLI not found (only needed locally)"

labels: check
	chmod +x $(LABEL_BOOTSTRAP)
	./$(LABEL_BOOTSTRAP)

codex-bootstrap: check
	@mkdir -p .github/ISSUE_TEMPLATE .github/workflows scripts/codex templates docs/historical codex/standards
	@echo "✅ Skeleton ensured."
	@echo "🔔 One-time reminders:"
	@echo "   1) Enable Issues (Settings → Features → Issues)"
	@echo "   2) Ensure Actions token permissions match your workflows"
	@echo "   3) Connect this repo to Codex Cloud so @codex on PRs works"
	$(MAKE) labels

# Generate CSV of tasks, then create issues -> workflow opens draft PRs + '@codex review'
batch: check
	@echo "🧠 Asking Codex to generate CSV + preambles…"
	codex exec --prompt "Scan ./ for atomic tasks and: (a) write ${CSV} with columns: title,size,branch,allowlist,tests,body_or_file,preamble_env,preamble_setup,preamble_tasks,preamble_artifacts; (b) for each task, write a markdown preamble at .codex/preambles/<slug>.md including sections: Environment, Setup, Tasks, Artifacts, Acceptance Criteria; (c) set body_or_file to that preamble file path for each row. Prefer S/M tasks."
	chmod +x $(BATCH_ISSUES)
	./$(BATCH_ISSUES) ${CSV} ${ISSUE_TEMPLATE}
	@echo "🧩 Issues created with preambles. Workflow will open draft PRs and summon @codex."

proof:
	codex

# Placeholder docs build target (adjust for your project)
docs:
	@echo "(placeholder) build docs" && exit 0

