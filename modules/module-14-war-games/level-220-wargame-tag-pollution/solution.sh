#!/usr/bin/env bash
set -e
git push -q origin --delete $(git tag -l 'build-*' | sed 's#^#refs/tags/#') 2>/dev/null
git tag -d $(git tag -l 'build-*') >/dev/null
hf=$(git log -1 --format=%H --grep='^fix: chart appVersion for 1.3.1$' main)
git tag -f -a v1.3.1 -m "Release 1.3.1" "$hf" >/dev/null
git push -q --force origin refs/tags/v1.3.1
git config fetch.prune true
git config fetch.pruneTags true
