#!/usr/bin/env bash
set -e

git switch feature/rebase
git reset --soft main
git commit -m "Squashed feature work"
