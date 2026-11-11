#!/usr/bin/env bash
set -e
for b in release/blue release/green; do
  git switch "$b"
  git stash apply
  git commit -am "Add SEO meta tags"
done
