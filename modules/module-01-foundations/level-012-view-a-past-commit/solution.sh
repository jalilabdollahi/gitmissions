#!/usr/bin/env bash
set -e
# Priya made exactly one commit; find it, then read the file as it was in that commit.
sha=$(git log --author=Priya --format=%H)
git show "$sha"
git show "$sha:rules/scoring.md" | grep -o '[0-9][0-9]* points' | grep -o '[0-9]*' > winning-score.txt
