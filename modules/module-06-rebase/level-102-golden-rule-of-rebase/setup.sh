#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git couponly 2>/dev/null
cd couponly
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'COUPONS = {}\n' > coupons.py
git add . && git commit -q -m "Create coupon registry"
git push -q origin main
git switch -q -c feature/coupon-engine
printf 'def apply(code, total):\n    return total\n' > engine.py
git add . && git commit -q -m "Add coupon engine"
printf 'def valid(code):\n    return bool(code)\n' > validate.py
git add . && git commit -q -m "Add coupon validation"
git push -q -u origin feature/coupon-engine

cd "$SANDBOX"
git clone -q origin.git mate 2>/dev/null
cd mate
git config user.name "Priya"
git config user.email "priya@couponly.dev"
git config commit.gpgsign false
printf 'def totals(items):\n    return sum(items)\n' > cart.py
git add . && git commit -q -m "Add cart totals"
git push -q origin main
git switch -q feature/coupon-engine
printf 'LIMIT = 3\n' > limits.py
git add . && git commit -q -m "Add coupon usage limits"
git push -q origin feature/coupon-engine

cd "$SANDBOX/couponly"
git fetch -q
git rebase -q origin/main
