#!/usr/bin/env bash
set -e
for i in 0 1 2 3; do
  if git stash show --name-only "stash@{$i}" | grep -qx legacy_search.py; then
    git stash drop "stash@{$i}"
    break
  fi
done
