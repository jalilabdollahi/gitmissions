#!/usr/bin/env bash
set -e
git rebase main
git switch main
git merge --ff-only feature/folders
