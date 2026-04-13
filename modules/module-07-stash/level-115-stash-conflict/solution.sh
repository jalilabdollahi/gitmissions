#!/usr/bin/env bash
set -e

git stash pop || true
printf 'resolved stash
' > app.txt
git add app.txt
git commit -m "Resolve stash conflict"
