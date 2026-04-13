#!/usr/bin/env bash
set -e

git switch feature/rebase
git rebase main || true
printf 'value=rebase
' > app.txt
git add app.txt
GIT_EDITOR=true git rebase --continue
