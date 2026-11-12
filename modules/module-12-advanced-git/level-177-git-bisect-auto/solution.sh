#!/usr/bin/env bash
set -e
git bisect start
git bisect bad HEAD
git bisect good "$(git rev-list --max-parents=0 HEAD)"
git bisect run ./check.sh
git tag first-bad refs/bisect/bad
git bisect reset
