#!/usr/bin/env bash
set -e
m=$(git log --merges --format=%H -1)
git revert -m 1 --no-edit "$m"
