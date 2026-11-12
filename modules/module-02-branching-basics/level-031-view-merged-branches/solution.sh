#!/usr/bin/env bash
set -e
git branch --merged main
# everything merged into main, except main itself
git branch --merged main | grep -v -e '^\*' -e ' main$' | xargs git branch -d
git branch
