#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"
git init -q --bare -b main origin.git
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
printf 'RATE = 1.08\n\ndef eur_to_usd(x):\n    return round(x * RATE, 2)\n' > converter.py
printf '#!/bin/sh\n# exits non-zero if the conversion rate is wrong\ngrep -q "^RATE = 1.08$" converter.py\n' > run_tests.sh
chmod +x run_tests.sh
ci Dana "2025-05-05T09:00:00" "Currency converter with smoke test"
git remote add origin ../origin.git
git push -q -u origin main
