#!/usr/bin/env bash
set -e

printf '*.log
build/
' > .gitignore
git add .gitignore
git commit -m "chore: add gitignore"
