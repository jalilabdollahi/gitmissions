#!/usr/bin/env bash
set -e
base=$(git merge-base main spring-concert)
echo "$base" > merge-base.txt
# three dots = changes on spring-concert since it left main (the "theirs" side of the merge)
git diff --name-only main...spring-concert | sort > spring-changes.txt
