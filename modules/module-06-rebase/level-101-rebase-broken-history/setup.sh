#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git stockwise 2>/dev/null
cd stockwise
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config pull.rebase false
printf 'STOCK = {}\n' > inventory.py
git add . && git commit -q -m "Create inventory"
git push -q origin main
git switch -q -c feature/stock-sync
printf 'def reserve(sku):\n    return sku\n' > reserve.py
git add . && git commit -q -m "Add stock reservation"
printf 'TTL = 900\n' > expiry.py
git add . && git commit -q -m "Add reservation expiry"
git push -q -u origin feature/stock-sync

cd "$SANDBOX"
git clone -q origin.git mate 2>/dev/null
cd mate
git config user.name "Dara"
git config user.email "dara@stockwise.dev"
git config commit.gpgsign false
printf 'WAREHOUSES = ["AMS", "BER"]\n' > warehouses.py
git add . && git commit -q -m "Add warehouse codes"
git push -q origin main
git switch -q feature/stock-sync
git rebase -q origin/main
git push -q --force origin feature/stock-sync

cd "$SANDBOX/stockwise"
printf 'THRESHOLD = 5\n' > lowstock.py
git add . && git commit -q -m "Add low-stock alert"
git pull -q --no-rebase --no-edit
