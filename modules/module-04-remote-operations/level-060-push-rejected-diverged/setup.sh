#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git pricing 2>/dev/null
cd pricing
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config pull.rebase false
printf 'BASE_FARE = 2.5\nPER_KM = 1.1\n' > fares.py
printf 'SURGE_CAP = 2.0\n' > surge.py
git add . && git commit -q -m "Base fare and surge cap"
git push -q origin main

cd "$SANDBOX"
git clone -q origin.git mate 2>/dev/null
cd mate
git config user.name "Tomas"
git config user.email "tomas@hailo.dev"
git config commit.gpgsign false
printf 'SURGE_CAP = 3.0\n' > surge.py
git commit -q -am "Raise surge cap to 3.0x for events"
git push -q origin main

cd "$SANDBOX/pricing"
printf 'AIRPORT_FEE = 6.0\n' > fees.py
git add . && git commit -q -m "Add airport pickup fee"
