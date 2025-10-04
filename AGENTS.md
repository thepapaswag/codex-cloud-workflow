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
```

