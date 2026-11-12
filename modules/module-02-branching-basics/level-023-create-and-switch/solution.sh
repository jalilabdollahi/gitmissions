#!/usr/bin/env bash
set -e
# Uncommitted changes travel with you when you create and switch in one step.
git switch -c winter-prices
git add prices.csv
git commit -m "Winter discount on workshop prices"
