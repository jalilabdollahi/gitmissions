#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git seed 2>/dev/null
cd seed
git config user.name "Sven"
git config user.email "sven@flagpole.dev"
git config commit.gpgsign false
printf 'flags: {}\n' > flags.yaml
git add . && git commit -q -m "Create flag store"
git push -q origin main
git switch -q -c staging
printf 'flags:\n  checkout-v2: off\n' > flags.yaml
git commit -q -am "Add checkout-v2 flag (off)"
git push -q origin staging

cd "$SANDBOX"
git clone -q origin.git flagpole 2>/dev/null
cd flagpole
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git checkout -q origin/staging 2>/dev/null
printf 'flags:\n  checkout-v2: on\n' > flags.yaml
git commit -q -am "Enable checkout-v2 flag in staging"
