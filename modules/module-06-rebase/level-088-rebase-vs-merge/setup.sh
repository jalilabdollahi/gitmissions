#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git seed 2>/dev/null
cd seed
git config user.name "Elif"
git config user.email "elif@tiergate.dev"
git config commit.gpgsign false
printf '<h1>Pricing</h1>\n' > pricing.html
git add . && git commit -q -m "Pricing page skeleton"
git push -q origin main
git switch -q -c release/pricing-v2
printf 'plans: [free, pro, team]\n' > plans.yaml
git add . && git commit -q -m "Define v2 plans"
printf 'discount: 20\n' > annual.yaml
git add . && git commit -q -m "Annual discount for v2"
git push -q origin release/pricing-v2
git switch -q main
printf 'badge: new\n' > badge.yaml
git add . && git commit -q -m "Add new-plan badge"
git push -q origin main

cd "$SANDBOX"
git clone -q origin.git tiergate 2>/dev/null
cd tiergate
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git switch -q -c release/pricing-v2 origin/release/pricing-v2
git switch -q main
git switch -q -c feature/pricing-toggle "$(git rev-parse main~1)"
printf 'toggle: monthly\n' > toggle.yaml
git add . && git commit -q -m "Add billing toggle"
printf 'persist: true\n' > persist.yaml
git add . && git commit -q -m "Persist toggle choice"
git switch -q main
