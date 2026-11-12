#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main billify
cd billify
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'TAX_RATE = 0.20\n\ndef total(net):\n    return net * (1 + TAX_RATE)\n' > billing.py && c "Compute invoice totals"
git switch -q -c feature/country-tax
printf 'TAX_RATE = {"NL": 0.20, "DE": 0.19}\n\ndef total(net):\n    return net * (1 + TAX_RATE["NL"])\n' > billing.py && c "Use per-country tax table"
printf 'def label(country):\n    return "tax-" + country\n' > labels.py && c "Add country argument to total"
git switch -q main
printf 'TAX_RATE = 0.21\n\ndef total(net):\n    return net * (1 + TAX_RATE)\n' > billing.py && c "Raise Dutch VAT to 21%"
git switch -q feature/country-tax
