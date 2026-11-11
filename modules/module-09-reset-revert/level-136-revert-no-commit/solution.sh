#!/usr/bin/env bash
set -e
git revert --no-commit HEAD~1 HEAD~2
git commit -q -m "Roll back discount experiments"
