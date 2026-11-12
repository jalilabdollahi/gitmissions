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
printf 'date,account,debit,credit\n2025-01-31,1000,500.00,\n2025-01-31,4000,,500.00\n' > journal.csv
printf '1000,Cash\n4000,Sales\n' > accounts.csv
ci Dana "2025-02-03T09:00:00" "Opening journal for January"
printf '2025-02-03,1000,120.00,\n2025-02-03,4000,,120.00\n' >> journal.csv
ci Dana "2025-02-04T09:00:00" "Post first February sale"
