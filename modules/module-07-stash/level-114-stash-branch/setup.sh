#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main geofence
cd geofence
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'APP = "geofence"\n' > app.py
git add . && git commit -q -m "Create courier app"
printf 'ZONES = ["A"]\n' > zones.py
git add . && git commit -q -m "Add zone list"
printf 'ZONES = ["A", "B"]\n' > zones.py
git stash push -q -m "zone B draft"
printf 'ZONES = ["Z"]\n' > zones.py
git commit -q -am "Rename zone A to Z"
