#!/usr/bin/env bash
set -e
# Log is newest first: HEAD~2 is the third commit from the top.
git log --format=%s -1 HEAD~2 > third-latest.txt
# The root commit is the one without parents; --max-parents=0 finds it.
git log --max-parents=0 --format=%h > first-commit.txt
