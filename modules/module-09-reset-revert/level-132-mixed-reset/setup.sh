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
mkdir rules
printf '"""Sales tax rules."""\nRULES = {}\n' > rules/__init__.py
ci Dana "2025-03-03T09:00:00" "Tax rule library skeleton"
printf 'RATE = 0.0625\nORIGIN_BASED = True\n' > rules/us_tx.py
ci Ravi "2025-03-05T10:00:00" "Add Texas sales tax rule"
printf 'RATE = 0.0725\nORIGIN_BASED = False\nDISTRICT_TAXES = True\n' > rules/us_ca.py
printf 'Ask legal whether CA district taxes apply to digital goods.\nClient X is negotiating a flat rate - do not publish.\n' > notes_private.txt
ci Ravi "2025-03-06T10:00:00" "Add California sales tax rule"
git rev-parse HEAD~1 > .git/gm-base
