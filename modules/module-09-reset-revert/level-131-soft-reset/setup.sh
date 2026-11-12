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
printf 'def hours(entries):\n    return sum(entries)\n' > timesheet.py
ci Dana "2025-02-03T09:00:00" "Start timesheet tool"
printf '\ndef overtime(entries, limit=40):\n    return max(0, hours(entries) - limit)\n' >> timesheet.py
ci Dana "2025-02-04T09:00:00" "Add overtime calculation"
sed -i.bak 's/limit=40/limit=40.0/' timesheet.py && rm timesheet.py.bak
ci Dana "2025-02-04T09:20:00" "fix overtime default"
sed -i.bak 's/return max(0, hours(entries) - limit)/return round(max(0, hours(entries) - limit), 2)/' timesheet.py && rm timesheet.py.bak
ci Dana "2025-02-04T09:45:00" "oops, round overtime"
git rev-parse 'HEAD^{tree}' > .git/gm-tree
