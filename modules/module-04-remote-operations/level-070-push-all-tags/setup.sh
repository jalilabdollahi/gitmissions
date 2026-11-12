#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git pointsmith 2>/dev/null
cd pointsmith
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'def earn(spend):\n    return spend // 10\n' > points.py
git add . && git commit -q -m "Earn points on spend"
git tag v1.0.0
printf 'def redeem(points):\n    return points * 0.01\n' >> points.py
git add . && git commit -q -m "Redeem points for discounts"
git tag v1.1.0
git tag scratch-benchmark
printf 'TIERS = ["silver", "gold"]\n' > tiers.py
git add . && git commit -q -m "Add loyalty tiers"
git tag -a v1.2.0 -m "Release 1.2.0: tiers"
git push -q origin main
