#!/usr/bin/env bash
set -e
git log --graph --oneline --decorate --all > invoice-history.txt
git branch --no-merged main --format='%(refname:short)' > unmerged.txt
