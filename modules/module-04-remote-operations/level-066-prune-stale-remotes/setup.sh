#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git seed 2>/dev/null
cd seed
git config user.name "Noor"
git config user.email "noor@staybridge.dev"
git config commit.gpgsign false
printf 'rooms: []\n' > rooms.yaml
git add . && git commit -q -m "Room inventory file"
git push -q origin main
for b in feature/late-checkout feature/pet-fees; do
  git switch -q -c "$b"
  printf '%s\n' "$b" > "$(printf '%s' "$b" | tr '/' '_').md"
  git add . && git commit -q -m "Add $b"
  git switch -q main
  git merge -q --no-ff "$b" -m "Merge $b"
  git push -q origin "$b"
done
git push -q origin main
git switch -q -c feature/spa-addons
printf 'spa: massage\n' > spa.yaml
git add . && git commit -q -m "Offer spa add-ons at booking"
git push -q origin feature/spa-addons
git switch -q main

cd "$SANDBOX"
git clone -q origin.git staybridge 2>/dev/null
cd staybridge
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git switch -q feature/late-checkout
git switch -q feature/spa-addons
git switch -q main

cd "$SANDBOX/seed"
git push -q origin --delete feature/late-checkout feature/pet-fees
