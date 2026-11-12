#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'RATES = {\n    "savings": 0.012,\n    "current": 0.001,\n    "business": 0.004,\n}\n' > rates.py
ci Dana "2025-10-06T09:00:00" "Interest rate table"
git switch -q -c maintenance/1.x
printf 'RATES = {\n    "savings": 0.012,\n    "current": 0.002,\n    "business": 0.004,\n}\n' > rates.py
ci Ravi "2025-10-07T10:00:00" "Adjust current account rate for 1.x"
git switch -q main
printf 'RATES = {\n    "savings": 0.012,\n    "current": 0.0005,\n    "overdraft": 0.19,\n    "business": 0.004,\n}\n' > rates.py
ci Mei "2025-10-08T10:00:00" "Add overdraft tier and lower current rate"
printf '# Rates\nSee rates.py. Overdraft is new in 2.0.\n' > README.md
ci Mei "2025-10-09T10:00:00" "Document the rate table"
git switch -q maintenance/1.x
