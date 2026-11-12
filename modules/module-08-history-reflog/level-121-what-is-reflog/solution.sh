#!/usr/bin/env bash
set -e
v1=$(git log -g --format=%H --grep='(draft)' -1)
echo "$v1" > first-draft.txt
git show "$v1:census.csv" | head -1 > draft-header.txt
