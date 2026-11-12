#!/usr/bin/env bash
set -e
git fetch
git cherry-pick origin/feature/step-goals
git push --force-with-lease
