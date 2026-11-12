#!/usr/bin/env bash
set -e
git stash pop || true
printf 'plans:\n  pro: 24\n  team: 50\n  enterprise: 90\n' > pricing.yaml
git add pricing.yaml
git commit -m "Add enterprise plan with new pro price"
git stash drop
