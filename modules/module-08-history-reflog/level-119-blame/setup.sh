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
mkdir parser
printf '# Fee schedule used when classifying statement lines\nINTL_FEE_CENTS = 250\nOVERDRAFT_FEE_CENTS = 2500\nATM_FEE_CENTS = 300\nMONTHLY_FEE_CENTS = 499\n' > parser/fees.py
ci Dana "2025-05-02T09:00:00" "Add fee schedule for statement parser"
sed -i.bak 's/^INTL_FEE_CENTS = 250/INTL_FEE_CENTS = 275/' parser/fees.py && rm parser/fees.py.bak
ci Ravi "2025-05-09T10:00:00" "Raise international fee"
sed -i.bak 's/^OVERDRAFT_FEE_CENTS = 2500/OVERDRAFT_FEE_CENTS = 3500/' parser/fees.py && rm parser/fees.py.bak
ci Priya "2025-05-16T14:20:00" "Align overdraft fee with the new tariff sheet"
sed -i.bak 's/^ATM_FEE_CENTS = 300/ATM_FEE_CENTS = 325/' parser/fees.py && rm parser/fees.py.bak
ci Tom "2025-05-21T08:30:00" "Update ATM fee"
printf '# Fee schedule used when classifying statement lines\nINTL_FEE_CENTS     = 275\nOVERDRAFT_FEE_CENTS = 3500\nATM_FEE_CENTS      = 325\nMONTHLY_FEE_CENTS  = 499\n' > parser/fees.py
ci Mei "2025-05-30T17:00:00" "Align the equals signs in fees.py"
