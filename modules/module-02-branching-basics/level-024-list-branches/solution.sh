#!/usr/bin/env bash
set -e
git branch -a
# remote branches that have no local counterpart
git for-each-ref refs/remotes --format='%(refname:lstrip=2)' | grep -v '^origin/HEAD$' | while read -r r; do
  git show-ref --verify -q "refs/heads/${r#origin/}" || echo "$r"
done > not-checked-out.txt
