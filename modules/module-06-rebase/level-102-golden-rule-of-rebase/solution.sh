#!/usr/bin/env bash
set -e
git reset --hard origin/feature/coupon-engine
git merge --no-edit origin/main
git push
