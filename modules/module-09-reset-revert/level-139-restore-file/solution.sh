#!/usr/bin/env bash
set -e
q2=$(git log --format=%h -1 --grep='Q2 rate card')
git restore --source="$q2" -- rates.csv
git add rates.csv
git commit -q -m "Restore Q2 rate card"
