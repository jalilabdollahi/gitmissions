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
mkdir -p engine
printf 'def render(invoice):\n    return "INVOICE %s" % invoice["id"]\n' > engine/render.py
ci Dana "2025-03-03T09:00:00" "Initial invoice renderer"
printf 'VAT_RATE = 0.19\n\ndef vat(net):\n    return round(net * VAT_RATE, 2)\n' > engine/vat.py
ci Dana "2025-03-04T10:15:00" "Add VAT calculation"

git switch -q -c feature/late-fees
printf 'LATE_FEE_PCT = 1.5\n' > engine/late_fees.py
ci Mei "2025-03-05T11:00:00" "Add late fee percentage"
printf 'def late_fee(amount, days):\n    return amount * LATE_FEE_PCT / 100 * days\n' >> engine/late_fees.py
ci Mei "2025-03-06T11:30:00" "Compute late fee per day"

git switch -q main
printf '\nFOOTER = "Thank you for your business"\n' >> engine/render.py
ci Dana "2025-03-07T09:40:00" "Add invoice footer"

git switch -q -c feature/credit-notes
printf 'def credit_note(invoice):\n    return {"ref": invoice["id"], "amount": -invoice["total"]}\n' > engine/credit.py
ci Ravi "2025-03-08T14:00:00" "Add credit note generator"

git switch -q main
D="2025-03-10T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q --no-ff feature/late-fees -m "Merge feature/late-fees"
printf 'ROUNDING = "half-up"\n' > engine/rounding.py
ci Dana "2025-03-11T10:00:00" "Pin rounding mode"

git switch -q -c experiment/proration
printf 'def prorate(amount, days_used, days_in_month):\n    return amount * days_used / days_in_month\n' > engine/proration.py
ci Tom "2025-03-12T16:00:00" "Prototype mid-month proration"
printf 'PRORATION_ENABLED = False\n' >> engine/proration.py
ci Tom "2025-03-13T09:20:00" "Guard proration behind a flag"

git switch -q main
D="2025-03-14T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q --no-ff feature/credit-notes -m "Merge feature/credit-notes"
