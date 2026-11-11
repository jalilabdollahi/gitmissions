#!/usr/bin/env bash
set -e
GIT_SEQUENCE_EDITOR="sed -i.bak -e '1s/^pick/edit/'" git rebase -i main
printf 'API_URL = "https://api.hookpay.dev"\nTIMEOUT = 5\n' > config.py
git add config.py
git commit -q --amend --no-edit
git rebase --continue
