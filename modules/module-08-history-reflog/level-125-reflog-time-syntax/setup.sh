#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'EUR,USD,1.0842\nEUR,GBP,0.8571\nEUR,JPY,162.40\n' > rates.csv
git add -A
D="2025-06-01T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git commit -q -m "Load ECB reference rates for 1 June"
printf 'EUR,USD,1.0861\nEUR,GBP,0.8566\nEUR,JPY,163.10\n' > rates.csv
git add -A
D="2025-06-02T10:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git commit -q -m "Load ECB reference rates for 2 June"
printf 'EUR,USD,1.0861\nEUR,GBP,0.8566\nEUR,JPY,161.55\n' > rates.csv
git add -A
D="2025-06-02T15:30:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git commit -q -m "Correct JPY rate for 2 June"
printf 'EUR,USD,108.61\nEUR,GBP,85.66\nEUR,JPY,16155\n' > rates.csv
git add -A
GIT_AUTHOR_DATE="2025-06-02T20:00:00" GIT_COMMITTER_DATE="2025-06-03T08:00:00" git commit -q -m "Load ECB reference rates for 3 June"
