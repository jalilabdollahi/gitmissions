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
printf 'def withdraw(balance, amount):\n    return balance - amount\n' > wallet.py
ci Dana "2025-08-04T09:00:00" "Wallet API 2.4 baseline"
git branch release/2.4
mkdir ledger
printf 'class Ledger:\n    pass\n' > ledger/core.py
ci Ravi "2025-08-05T10:00:00" "Refactor ledger module into a package"
printf 'def withdraw(balance, amount):\n    if amount <= 0:\n        raise ValueError("amount must be positive")\n    return balance - amount\n' > wallet.py
ci Mei "2025-08-06T10:00:00" "Reject negative withdrawal amounts"
printf 'def export_csv(txns):\n    return "\\n".join(map(str, txns))\n' > export.py
ci Tom "2025-08-07T10:00:00" "Add wallet CSV export"
git rev-parse HEAD > .git/gm-tip
