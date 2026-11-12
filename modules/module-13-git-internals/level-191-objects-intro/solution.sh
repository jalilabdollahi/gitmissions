#!/usr/bin/env bash
set -e
types=$(git rev-list --objects main | cut -d' ' -f1 | git cat-file --batch-check='%(objecttype)')
{
  echo "head_tree=$(git rev-parse 'main^{tree}')"
  echo "v1_sensors_blob=$(git rev-parse v1.0:sensors.toml)"
  echo "v1_tag_object=$(git rev-parse v1.0)"
  echo "v1_tag_target_type=$(git cat-file -p v1.0 | sed -n 's/^type //p')"
  echo "commits=$(printf '%s\n' "$types" | grep -c '^commit$')"
  echo "trees=$(printf '%s\n' "$types" | grep -c '^tree$')"
  echo "blobs=$(printf '%s\n' "$types" | grep -c '^blob$')"
} > objects.txt
