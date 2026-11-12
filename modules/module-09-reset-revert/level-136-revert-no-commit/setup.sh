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
mkdir discounts
printf 'def total(lines):\n    return sum(qty * price for qty, price in lines)\n' > invoice.py
printf 'Thank you for your order.\n' > footer.txt
ci Dana "2025-03-10T09:00:00" "Invoice engine baseline"
printf 'def loyalty(total, years):\n    return total * min(years, 5) * 0.01\n' > discounts/loyalty.py
ci Ravi "2025-03-11T10:00:00" "Add loyalty discount experiment"
printf 'def seasonal(total, month):\n    return total * 0.1 if month == 12 else 0\n' > discounts/seasonal.py
ci Ravi "2025-03-12T10:00:00" "Add seasonal discount experiment"
printf 'Thank you for your order.\nQuestions? billing@example.dev\n' > footer.txt
ci Mei "2025-03-13T10:00:00" "Add billing contact to the footer"
git rev-parse HEAD > .git/gm-tip
