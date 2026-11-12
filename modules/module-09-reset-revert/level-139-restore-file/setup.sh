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
printf 'term_years,apr\n15,0.0525\n30,0.0575\n' > rates.csv
printf 'def monthly_payment(principal, apr, years):\n    r = apr / 12\n    n = years * 12\n    return principal * r / (1 - (1 + r) ** -n)\n' > loan.py
ci Dana "2025-01-06T09:00:00" "Initial amortization calculator"
printf 'term_years,apr\n15,0.0549\n30,0.0612\n' > rates.csv
ci Ravi "2025-04-01T09:00:00" "Q2 rate card"
printf 'term_years,apr\n15,0\n30,0\n' > rates.csv
ci Tom "2025-04-22T09:00:00" "Import vendor rate dump"
printf 'def monthly_payment(principal, apr, years):\n    if apr == 0:\n        return principal / (years * 12)\n    r = apr / 12\n    n = years * 12\n    return principal * r / (1 - (1 + r) ** -n)\n' > loan.py
ci Mei "2025-04-23T09:00:00" "Handle zero-rate loans"
git rev-parse HEAD > .git/gm-tip
