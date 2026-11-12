#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main opsboard
cd opsboard
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf '<main id="board"></main>\n' > dashboard.html && c "Add dashboard layout"
printf 'ORDERS = []\n' > orders.py && c "Add order table"
printf 'def revenue(orders):\n    return sum(o["total"] for o in orders)\n' > revenue.py && c "Add revenue chart data"
git switch -q --detach
printf 'import csv\n\ndef export(rows, fh):\n    csv.writer(fh).writerows(rows)\n' > export.py && c "Add CSV export endpoint"
printf '<main id="board"><button id="export">Export</button></main>\n' > dashboard.html && c "Add export button"
git switch -q main
