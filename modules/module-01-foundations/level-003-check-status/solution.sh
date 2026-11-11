#!/usr/bin/env bash
set -e
git status
git diff --cached --name-only > staged.txt
git ls-files --others --exclude-standard | grep -v -e '^staged.txt$' -e '^untracked.txt$' > untracked.txt
