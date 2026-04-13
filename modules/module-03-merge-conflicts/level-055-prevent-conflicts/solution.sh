#!/usr/bin/env bash
set -e

git switch feature/prevent
git rebase main
git switch main
git merge feature/prevent
