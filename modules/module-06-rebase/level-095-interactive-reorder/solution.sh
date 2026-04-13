#!/usr/bin/env bash
set -e

git reset --hard HEAD~2
printf 'one
' > one.txt
git add one.txt
git commit -m "First step"
printf 'two
' > two.txt
git add two.txt
git commit -m "Second step"
