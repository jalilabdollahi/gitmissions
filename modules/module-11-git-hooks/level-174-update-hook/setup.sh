#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"
git init -q --bare -b main origin.git
git -C origin.git config core.hooksPath hooks
git init -q -b main work
cd work
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
printf 'filing,period,status\n10-K,2024,submitted\n' > filings.csv
ci Dana "2025-02-03T09:00:00" "Archive the 2024 annual filing"
git tag -a filing-2024-Q4 -m "Q4 2024 filing as submitted"
git remote add origin ../origin.git
git push -q -u origin main
git push -q origin filing-2024-Q4
printf '10-Q,2025Q1,draft\n' >> filings.csv
ci Dana "2025-04-07T09:00:00" "Add the Q1 2025 draft"
