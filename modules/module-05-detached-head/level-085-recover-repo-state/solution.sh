#!/usr/bin/env bash
set -e
git branch hotfix/2.4.1 HEAD@{1}
git tag -a v2.4.1 hotfix/2.4.1 -m "Release 2.4.1"
git merge --no-ff hotfix/2.4.1 -m "Merge hotfix 2.4.1" || true
printf 'ETA_BUFFER_MIN = 15\nROUND_TO = 1\n' > eta.py
git add eta.py
git commit -q --no-edit
