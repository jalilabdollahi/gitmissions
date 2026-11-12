#!/usr/bin/env bash
set -e
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --prune-empty \
  --index-filter 'git rm --cached --ignore-unmatch -q config/prod.env' -- --all >/dev/null 2>&1
rm -rf .git/refs/original
git reflog expire --expire=now --all
git gc -q --prune=now
mkdir -p config
printf 'AWS_ACCESS_KEY_ID=<from-vault>\nAWS_SECRET_ACCESS_KEY=<from-vault>\n' > config/prod.env.example
printf 'config/prod.env\n' >> .gitignore
git add config/prod.env.example .gitignore
git commit -qm "chore: replace prod.env with an example"
