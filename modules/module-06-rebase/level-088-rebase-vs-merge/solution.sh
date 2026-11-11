#!/usr/bin/env bash
set -e
git merge --no-edit origin/release/pricing-v2
git rebase main feature/pricing-toggle
git switch main
git merge --ff-only feature/pricing-toggle
