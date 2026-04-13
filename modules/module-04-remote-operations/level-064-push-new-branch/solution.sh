#!/usr/bin/env bash
set -e

git switch -c feature/ui
printf 'ui
' > ui.txt
git add ui.txt
git commit -m "Add UI work"
git push -u origin feature/ui
