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
mkdir cli
printf 'import sys\n\ndef main():\n    print("ledger", sys.argv[1:])\n' > cli/main.py
printf 'Usage: ledger <command>\n' > cli/USAGE.txt
ci Dana "2025-04-07T09:00:00" "Ledger CLI entry point"
git switch -q -c topic
printf 'def balance(account):\n    return 0\n' > cli/balance.py
ci Dana "2025-04-08T09:00:00" "feat(cli): add balance command"
git switch -q main
