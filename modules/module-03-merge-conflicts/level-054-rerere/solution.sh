#!/usr/bin/env bash
set -e

git config rerere.enabled true
printf 'value=main+feature
' > app.txt
git add app.txt
git commit -m "Resolve merge conflict"
