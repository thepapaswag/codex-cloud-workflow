# Codex Cloud Environment (CPU-only)

This repository ships a small, reusable layer to make Codex Cloud runs reproducible and CPU-only by default, regardless of any local GPU setup.

## Components
- `.codex/cloud.env` — environment flags that disable GPU usage and set common CPU-only toggles.
- `.codex/setup.sh` — dependency bootstrapper that detects common project types and installs dependencies without sudo/apt.
- Optional `requirements-cloud.txt` — project-specific CPU-only Python requirements (if present, it is preferred by the setup script).

## Defaults
- CPU-only: `CUDA_VISIBLE_DEVICES=""`. Additional toggles for Accelerate/JAX are included but harmless if unused.
- Language managers only: pip/npm/pnpm/yarn/go; no system package managers.
- Best-effort detection: Python (venv + pip), Node (prefer lockfile, otherwise install), Go (`go mod download`).

## Recommended Patterns
### Python
- Prefer CPU variants where applicable:
  - `faiss-cpu`, `tensorflow-cpu`, `jax[cpu]`
  - PyTorch CPU (example): `pip install --index-url https://download.pytorch.org/whl/cpu torch torchvision torchaudio`
- Keep a `requirements-cloud.txt` that replaces any GPU-specific packages used locally.
- Mark GPU-dependent tests and skip by default in CI/Cloud, e.g. with pytest markers.

### Node
- Commit a lockfile and prefer `npm ci` (or pnpm/yarn with frozen lockfiles) for reproducible installs.

### Go
- Use modules; `go mod download` will fetch dependencies.

## Usage in Issues
In the Issue Form (Preamble):
- Environment:
  ```
  source .codex/cloud.env
  ```
- Setup:
  ```
  bash .codex/setup.sh
  ```

## Local GPUs vs Cloud CPU
Local development may use NVIDIA/ROCm. Codex Cloud will remain CPU-only, which keeps tasks portable and avoids device mismatches. If a task truly requires GPUs, call this out explicitly in the Issue and handle outside the default Codex Cloud path.

## Notes
- Adjust `requirements-cloud.txt` per project if you use heavy ML stacks.
- The setup script is conservative; extend it in downstream projects if needed.

