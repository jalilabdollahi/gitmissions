#!/usr/bin/env bash
set -e
# main is shared: revert, then push
git switch main
git revert --no-edit "$(git log --format=%h -1 --grep='Switch rounding to floor')"
git push origin main
# feature branch is local-only: simply drop the WIP commit
git switch feature/fx-fees
git reset --hard HEAD~1
