#!/usr/bin/env bash
set -e
git remote add upstream ../upstream.git
git fetch upstream
git switch main
git merge --ff-only upstream/main
git push origin main
