#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main adserve
cd adserve
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf '# adserve\n' > README.md && c "Add readme"
git switch -q -c feature/campaigns
printf 'BUDGET = None\n' > campaign.py && c "Add campaign model"
printf 'CAP_PER_DAY = None\n' > budget.py && c "Add budget caps"
printf 'GEO = None\n' > targeting.py && c "Add targeting rules"
printf 'def report():\n    return {}\n' > report.py && c "Add reporting endpoint"
printf 'CAP_PER_DAY = 100\n' > budget.py
git add -A && git commit -q --fixup="$(git log -1 --format=%H --grep='Add budget caps')"
printf 'BUDGET = 0\n' > campaign.py
git add -A && git commit -q --fixup="$(git log -1 --format=%H --grep='Add campaign model')"
printf 'GEO = "EU"\n' > targeting.py
git add -A && git commit -q --fixup="$(git log -1 --format=%H --grep='Add targeting rules')"
