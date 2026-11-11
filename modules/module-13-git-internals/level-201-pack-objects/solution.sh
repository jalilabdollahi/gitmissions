#!/usr/bin/env bash
set -e
git rev-list --objects --all | git pack-objects -q .git/objects/pack/pack
git prune-packed
git verify-pack -v .git/objects/pack/*.idx \
  | awk '$2=="blob" || $2=="tree" || $2=="commit" {print $3, $1}' | sort -n | tail -1 | cut -d' ' -f2 > biggest.txt
