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
    cat > progress.json <<'EOF'
{"player_name":null,"total_xp":0,"completed_levels":[],"current_module":"module-01-foundations","current_level":"level-001-init-your-first-repo","module_certificates":[],"time_per_level":{},"level_start_time":null,"hint_state":{}}
EOF
    echo "Progress reset. Starting again from Module 1 Level 1."
    exit 0
  else
    echo "Cancelled."
    exit 0
  fi
fi

if [ -f ".venv/bin/activate" ]; then
  source .venv/bin/activate
fi

PYTHONPATH="$REPO" python3 -m engine.engine "$@"
