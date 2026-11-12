#!/usr/bin/env bash
set -e
git stash list
for i in 0 1 2 3; do
  if git stash show --name-only "stash@{$i}" | grep -qx pricing.py; then
    git stash pop "stash@{$i}"
    break
  fi
done
