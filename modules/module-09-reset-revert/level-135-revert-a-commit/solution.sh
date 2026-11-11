#!/usr/bin/env bash
set -e
bad=$(git log --format=%h -1 --grep='Raise motor current limit')
git revert --no-edit "$bad"
