#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")" && pwd)"
cd "$REPO"

echo "Setting up GitMissions..."

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is not installed"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is not installed"
  exit 1
fi

# Recreate the virtualenv if it is missing or its interpreter no longer runs
# (for example after a Python upgrade or when copied from another machine).
if [ -d ".venv" ] && ! .venv/bin/python -c "import sys" >/dev/null 2>&1; then
  echo "Existing .venv is broken; recreating it..."
  rm -rf .venv
fi

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

.venv/bin/python -m pip install --quiet --upgrade pip
.venv/bin/python -m pip install --quiet -r requirements.txt
.venv/bin/python scripts/generate_registry.py

echo "GitMissions is ready. Start the game with: ./play.sh"
echo "Maintainers: verify every level with .venv/bin/python scripts/build_levels.py"
