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

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate
python3 -m pip install --quiet --upgrade pip
python3 -m pip install --quiet -r requirements.txt
python3 scripts/generate_levels.py
python3 scripts/generate_registry.py

if [ ! -f progress.json ]; then
  cat > progress.json <<'EOF'
{"player_name":null,"total_xp":0,"completed_levels":[],"current_module":"module-01-foundations","current_level":"level-001-init-your-first-repo","module_certificates":[],"time_per_level":{},"level_start_time":null,"hint_state":{}}
EOF
fi

echo "GitMissions is ready."
echo "Activate the virtual environment with: source .venv/bin/activate"
echo "Then start the game with: ./play.sh"
