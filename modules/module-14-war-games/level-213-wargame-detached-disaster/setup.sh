#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main origin.git
git clone -q origin.git work 2>/dev/null
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir server docs
printf 'MAX_LOBBY = 16\n\ndef open_lobby(size):\n    return size <= MAX_LOBBY\n' > server/lobby.py
printf 'def join(token):\n    return bool(token)\n' > server/auth.py
printf '# Runbook\n\n## Restart\nsystemctl restart matchmaker\n' > docs/runbook.md
git add -A; ci Tove tove@game.dev "2025-10-01T09:00:00" "Matchmaker 2.3 baseline"
printf 'REGIONS = ["eu", "us"]\n' > server/regions.py
git add -A; ci Tove tove@game.dev "2025-10-06T09:00:00" "Regions list"
git tag v2.3.0
printf 'REGIONS = ["eu", "us", "ap"]\n' > server/regions.py
git add -A; ci Tove tove@game.dev "2025-10-14T09:00:00" "Add ap region"
printf 'def rank(a, b):\n    return a - b\n' > server/rank.py
git add -A; ci Tove tove@game.dev "2025-10-20T09:00:00" "Skill ranking prototype"
git push -q origin main --tags 2>/dev/null
git switch -q --detach v2.3.0
printf 'MAX_LOBBY = 8\n\ndef open_lobby(size):\n    return size <= MAX_LOBBY\n' > server/lobby.py
git add -A; ci Player player@gitmissions.local "2025-10-22T09:00:00" "fix: cap lobby size at 8"
printf 'SEEN = set()\n\ndef join(token):\n    if token in SEEN:\n        return False\n    SEEN.add(token)\n    return bool(token)\n' > server/auth.py
git add -A; ci Player player@gitmissions.local "2025-10-22T11:00:00" "fix: reject duplicate join tokens"
printf '\n## Failover\nPromote the standby with ./promote.sh\n' >> docs/runbook.md
git add docs/runbook.md
