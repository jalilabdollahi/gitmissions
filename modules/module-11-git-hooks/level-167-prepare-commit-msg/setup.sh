#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config core.hooksPath .git/hooks

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
mkdir recon
printf 'def match(bank_rows, ledger_rows):\n    return []\n' > recon/matcher.py
printf 'tolerance_cents: 1\n' > recon/config.yaml
ci Dana "2025-06-09T09:00:00" "FIN-100: Reconciliation job skeleton"
git switch -q -c feature/FIN-204-rounding
