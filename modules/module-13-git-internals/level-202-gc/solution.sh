#!/usr/bin/env bash
set -e
tip=$(git log -g --format='%H %s' | awk '/ geo: country allowlist for flags$/ {print $1; exit}')
git branch rescue/geo-flags "$tip"
git reflog expire --expire=now --all
git gc -q --prune=now
