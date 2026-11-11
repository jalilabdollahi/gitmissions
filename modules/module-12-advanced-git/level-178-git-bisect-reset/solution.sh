#!/usr/bin/env bash
set -e
git bisect log > bisect-session.log
culprit=$(git rev-parse refs/bisect/bad)
git bisect reset
git revert --no-edit "$culprit"
