#!/usr/bin/env bash
set -e

printf 'secrets.env
' > .gitignore
git rm --cached secrets.env
git add .gitignore
git commit -m "chore: ignore secrets"
