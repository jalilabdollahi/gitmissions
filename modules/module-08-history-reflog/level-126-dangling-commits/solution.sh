#!/usr/bin/env bash
set -e
git fsck --lost-found --no-reflogs 2>/dev/null | grep 'dangling commit' | while read -r _ _ sha; do
  if git show "$sha:adjustments.csv" | grep -q E-4471; then git branch rescued-adjustments "$sha"; fi
done
