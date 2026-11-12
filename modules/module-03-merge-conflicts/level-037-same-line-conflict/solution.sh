#!/usr/bin/env bash
set -e
git merge waiting-list || true
# The fire marshal's limit (docs/venue.md) is the only number that is allowed.
limit=$(grep -o 'occupancy [0-9]*' docs/venue.md | grep -o '[0-9]*')
printf 'EVENT = "Class of 2005 reunion"\nMAX_GUESTS = %s\nSEND_REMINDERS = True\n' "$limit" > config.py
git add config.py
git commit -m "Merge waiting-list: cap guests at the fire marshal limit"
