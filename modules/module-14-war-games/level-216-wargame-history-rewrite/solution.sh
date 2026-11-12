#!/usr/bin/env bash
set -e
picks=$(git log --reverse -E --author='Kai|Lena' --format=%H ORIG_HEAD)
git cherry-pick $picks >/dev/null
git push -q origin develop
new=$(git log -1 --format=%H --grep='^client: ttl helpers$')
git tag -f -a v0.4.0 -m "v0.4.0" "$new" >/dev/null
git push -q --force origin v0.4.0
