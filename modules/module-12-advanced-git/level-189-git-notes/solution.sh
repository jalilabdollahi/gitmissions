#!/usr/bin/env bash
set -e
for f in $(cat prod-applied.txt); do
  c=$(git log --diff-filter=A --format=%H -- "migrations/$f")
  git notes --ref=deploy add -m "applied: prod" "$c"
done
git push -q origin refs/notes/deploy
