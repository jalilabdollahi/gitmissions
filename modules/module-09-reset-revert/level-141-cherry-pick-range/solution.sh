#!/usr/bin/env bash
set -e

git switch main
git cherry-pick feature/pick
