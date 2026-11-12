#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main billwise
cd billwise
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf '# billwise\n' > NOTES.md && c "Add notes"
git switch -q -c feature/proration
printf 'DAYS=30\necho $(($1 * $2 / DAYS))\n' > prorate.sh
printf '[ "$(sh prorate.sh 3000 10)" = 1000 ]\n' > test.sh && c "Add proration calculator"
printf 'DAYS=${BILLING_DAYS:-31}\necho $(($1 * $2 / DAYS))\n' > prorate.sh && c "Parametrize billing days"
printf '# Proration\nprice * days / 30\n' > README.md && c "Document proration"
printf 'DAYS=${BILLING_DAYS:-30}\necho $(($1 * $2 / DAYS))\n' > prorate.sh && c "Fix default billing days"
printf 'YEARLY=12\n' > plans.sh && c "Add yearly plan"
