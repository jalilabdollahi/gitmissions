#!/usr/bin/env bash
set -e
git fetch --prune
# merged into main, excluding main itself and release/*
git push origin --delete feature/salary-filter feature/saved-searches
