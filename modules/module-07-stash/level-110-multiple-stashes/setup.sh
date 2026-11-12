#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main pedalpoint
cd pedalpoint
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'STATIONS = []\n' > stations.py
printf 'def search(q):\n    return []\n' > search.py
printf 'TILE_SIZE = 256\n' > tiles.py
printf 'SURGE = 1.0\n' > pricing.py
git add . && git commit -q -m "Seed bike-share modules"
printf 'TILE_SIZE = 512\n' > tiles.py && git stash -q
printf 'SURGE = 1.5\n' > pricing.py && git stash -q
printf 'def search(q):\n    return [q]\n' > search.py && git stash -q
printf 'STATIONS = ["central"]\n' > stations.py && git stash -q
