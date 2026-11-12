#!/usr/bin/env bash
set -e
# Renaming the branch you are on: -m <new-name>
git branch -m fix/password-reset
# Renaming another branch: -m <old> <new>
git branch -m master main
git branch
