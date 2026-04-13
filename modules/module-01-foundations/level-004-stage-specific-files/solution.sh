#!/usr/bin/env bash
set -e

git add app.txt
git commit -m "feat: update app file"
rm -f notes.txt draft.txt
