#!/usr/bin/env bash
set -e
for i in 0 1 2 3 4; do
  if git stash show --name-only "stash@{$i}" | grep -qx rate_limit.py; then
    git stash show -p "stash@{$i}" > keep.patch
    break
  fi
done
git stash clear
