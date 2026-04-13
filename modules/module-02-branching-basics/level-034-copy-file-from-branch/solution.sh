#!/usr/bin/env bash
set -e

git switch main
git checkout feature/docs -- release.md
git add release.md
git commit -m "docs: copy release notes"
