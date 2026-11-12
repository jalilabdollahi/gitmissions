#!/usr/bin/env bash
set -e
for f in $(git ls-files); do
  sha=$(git hash-object "$f")
  if ! git cat-file blob "$sha" >/dev/null 2>&1; then
    rm -f ".git/objects/$(printf '%s' "$sha" | cut -c1-2)/$(printf '%s' "$sha" | cut -c3-)"
    git hash-object -w "$f" >/dev/null
  fi
done
git fsck --full --strict
