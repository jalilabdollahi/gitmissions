#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main billsplit
cd billsplit
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'BILLS = []\n' > bills.py && c "Create bill model"
git switch -q -c feature/payments-api
printf 'def intent(amount):\n    return {"amount": amount}\n' > payments.py && c "Add payment intents API"
printf 'def on_event(e):\n    return e\n' > webhooks.py && c "Add payment webhooks"
git switch -q -c feature/refund-ui
printf 'def refund_screen():\n    return "refund"\n' > refund_ui.py && c "Add refund screen"
printf 'def toast():\n    return "Refunded"\n' > toast.py && c "Add refund confirmation toast"
git switch -q main
git merge -q --squash feature/payments-api
git commit -q -m "Add payments API (#88)"
printf '# Billing docs\n' > docs.md && c "Update billing docs"
git switch -q feature/refund-ui
