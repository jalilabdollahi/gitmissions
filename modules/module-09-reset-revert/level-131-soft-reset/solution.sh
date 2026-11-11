#!/usr/bin/env bash
set -e
git reset --soft HEAD~3
git commit -q -m "Add overtime calculation with rounding"
