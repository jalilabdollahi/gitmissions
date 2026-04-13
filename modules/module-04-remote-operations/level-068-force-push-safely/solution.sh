#!/usr/bin/env bash
set -e

git commit --amend -m "Rewrite local commit"
git push --force-with-lease origin main
