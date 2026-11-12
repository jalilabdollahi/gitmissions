#!/usr/bin/env bash
set -e
root=$(git rev-list --max-parents=0 main)
merge=$(git rev-list --merges main)
{
  echo "root_tree=$(git cat-file -p "$root" | awk '/^tree/{print $2}')"
  echo "merge_commit=$merge"
  echo "second_parent=$(git cat-file -p "$merge" | awk '/^parent/{n++; if (n==2) print $2}')"
  echo "rewritten_commit=$(git log --format='%H %ae %ce' main | awk '$2 != $3 {print $1}')"
} > forensics.txt
