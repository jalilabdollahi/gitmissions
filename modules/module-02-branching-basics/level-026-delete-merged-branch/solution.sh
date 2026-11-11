#!/usr/bin/env bash
set -e
# You cannot delete the branch you are standing on.
git switch main
git branch -d old-layout typo-fix
git branch
