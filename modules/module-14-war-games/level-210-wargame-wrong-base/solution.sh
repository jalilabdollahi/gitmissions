#!/usr/bin/env bash
set -e
git fetch -q origin
git rebase -q --onto origin/main experiment/new-router feature/rate-limit
git push -q --force-with-lease origin feature/rate-limit
git branch -q --set-upstream-to=origin/feature/rate-limit
