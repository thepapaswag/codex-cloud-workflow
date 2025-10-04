#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")
cd "$ROOT_DIR"

if [ -f ./.codex/cloud.env ]; then
  # shellcheck disable=SC1091
  source ./.codex/cloud.env
fi

echo "[codex-setup] Starting language bootstrap (CPU-only defaults)"

# ---------- Python ----------
if [ -f pyproject.toml ] || ls requirements*.txt >/dev/null 2>&1; then
  echo "[codex-setup] Python project detected"
  PYTHON_BIN=${PYTHON_BIN:-python3}
  if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    echo "[codex-setup] python3 not found; skipping Python setup" >&2
  else
    VENV_DIR=.venv
    "$PYTHON_BIN" -m venv "$VENV_DIR" || "$PYTHON_BIN" -m virtualenv "$VENV_DIR"
    # shellcheck disable=SC1090
    source "$VENV_DIR"/bin/activate
    python -m pip install --upgrade pip
    if [ -f requirements-cloud.txt ]; then
      echo "[codex-setup] Installing requirements-cloud.txt"
      pip install -r requirements-cloud.txt
    elif [ -f requirements.txt ]; then
      echo "[codex-setup] Installing requirements.txt"
      pip install -r requirements.txt
    elif grep -q "\[project\]" pyproject.toml 2>/dev/null; then
      echo "[codex-setup] Installing from pyproject (PEP 621)"
      pip install .
    else
      echo "[codex-setup] No known Python dependency file; skipping install"
    fi
  fi
fi

# ---------- Node ----------
if [ -f package.json ]; then
  echo "[codex-setup] Node project detected"
  if command -v npm >/dev/null 2>&1 && [ -f package-lock.json ]; then
    npm ci || npm install --no-audit --no-fund
  elif command -v pnpm >/dev/null 2>&1 && [ -f pnpm-lock.yaml ]; then
    pnpm install --frozen-lockfile || pnpm install
  elif command -v yarn >/dev/null 2>&1 && [ -f yarn.lock ]; then
    yarn install --frozen-lockfile || yarn install
  else
    echo "[codex-setup] No suitable Node package manager/lockfile; skipping"
  fi
fi

# ---------- Go ----------
if [ -f go.mod ] && command -v go >/dev/null 2>&1; then
  echo "[codex-setup] Go project detected"
  go mod download
fi

echo "[codex-setup] Done"

