#!/usr/bin/env bash
set -e

git reset --hard HEAD~2
printf 'final
' > final.txt
git add final.txt
git commit -m "Final work"
