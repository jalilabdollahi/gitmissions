#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main taxwise
cd taxwise
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'VAT_DE = 0.19\n' > invoice_tax.py && c "Add German VAT"
printf 'def net(gross, rate):\n    return gross / (1 + rate)\n' > invoice.py && c "Compute net amounts"
printf '# invoices\n' > README.md && c "Add readme"
git switch -q --detach
printf 'FLAT = 0.25\n' > experiments.py && c "Experiment: flat 25% tax everywhere"
git switch -q main
git switch -q --detach
printf 'VAT_NL = 0.21\n' >> invoice_tax.py && c "Add VAT 21% for Dutch invoices"
git switch -q main
git switch -q --detach
printf 'ROUND = "bankers"\n' > rounding.py && c "Experiment: banker's rounding on totals"
git switch -q main
