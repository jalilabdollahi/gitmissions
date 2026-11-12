#!/usr/bin/env bash
set -e
body=$(git log --reverse --format='- %s' HEAD^1..HEAD^2)
git commit --amend -m "Merge dark mode into main" -m "$body"
git log -1
