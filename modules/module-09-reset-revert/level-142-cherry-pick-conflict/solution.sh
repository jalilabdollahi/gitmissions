#!/usr/bin/env bash
set -e
pick=$(git log main --format=%h -1 --grep='Add overdraft tier')
git cherry-pick "$pick" || true
cat > rates.py <<'PY'
RATES = {
    "savings": 0.012,
    "current": 0.002,
    "overdraft": 0.19,
    "business": 0.004,
}
PY
git add rates.py
GIT_EDITOR=true git cherry-pick --continue
