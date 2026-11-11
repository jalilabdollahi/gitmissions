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
mkdir feeds
printf '{"base": "EUR", "rates": {"USD": 1.08}}\n' > feeds/rates.json
printf '{"calendar": "TARGET2", "holidays": ["2025-12-25"]}\n' > feeds/holidays.json
printf '# Feeds\nEach JSON file is loaded by the nightly importer.\n' > README.md
ci Dana "2025-03-03T09:00:00" "Add market data feeds"
