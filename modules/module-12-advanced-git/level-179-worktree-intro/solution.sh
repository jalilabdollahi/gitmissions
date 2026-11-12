#!/usr/bin/env bash
set -e
git worktree add --detach ../wt-v1 v1.0
git worktree add --detach ../wt-v2 v2.0
{
  echo "v1.0 $(cd ../wt-v1 && ./bench.sh)"
  echo "v2.0 $(cd ../wt-v2 && ./bench.sh)"
} > compare.txt
