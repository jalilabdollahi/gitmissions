#!/usr/bin/env bash
set -e

git merge --abort || true
git switch main || git switch -c main
printf 'recovered
' > rescue.txt
git add rescue.txt
git commit -m "fix: war game recovery"
