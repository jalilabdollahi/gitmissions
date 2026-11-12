#!/usr/bin/env bash
set -e
git bisect start
git bisect bad
git bisect good "$(git rev-list --max-parents=0 HEAD)"
git bisect run sh check.sh
git rev-parse --short refs/bisect/bad > culprit.txt
git bisect reset
