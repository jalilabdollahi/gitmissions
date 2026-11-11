#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main tierprice
cd tierprice
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'plans:\n  pro: 20\n  team: 50\n' > pricing.yaml
git add . && git commit -q -m "Define subscription plans"
printf 'plans:\n  pro: 18\n  team: 50\n  enterprise: 90\n' > pricing.yaml
git stash push -q -m "enterprise plan draft"
printf 'plans:\n  pro: 24\n  team: 50\n' > pricing.yaml
git commit -q -am "Raise pro price to 24"
