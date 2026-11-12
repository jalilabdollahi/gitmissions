#!/usr/bin/env bash
set -e
for f in inbox/*; do
  echo "$(git hash-object -w "$f") $f"
done > MANIFEST.txt
f=inbox/rotation-plan.txt
{ printf 'blob %s\0' "$(wc -c < "$f" | tr -d ' ')"; cat "$f"; } | { shasum 2>/dev/null || sha1sum; } | cut -d' ' -f1 > manual-sha.txt
