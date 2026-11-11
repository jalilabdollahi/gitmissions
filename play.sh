#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO"

if [[ "${1:-}" == "--reset" ]]; then
  if [ ! -f "progress.json" ]; then
    echo "No progress file found; nothing to reset."
    exit 0
  fi

  read -r -p "Reset all GitMissions progress? This cannot be undone. [y/N] " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -f progress.json
    echo "Progress reset. Starting again from Module 1 Level 1."
  else
    echo "Cancelled."
  fi
  exit 0
fi

PYTHON=".venv/bin/python"
if ! "$PYTHON" -c "import rich, yaml" >/dev/null 2>&1; then
  echo "The Python environment is missing or broken. Run ./install.sh first."
  exit 1
fi

PYTHONPATH="$REPO" exec "$PYTHON" -m engine.engine "$@"
