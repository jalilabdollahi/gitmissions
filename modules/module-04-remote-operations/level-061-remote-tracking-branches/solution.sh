#!/usr/bin/env bash
set -e
git fetch
git branch -r --no-merged origin/main | sed 's#^ *origin/##' > unmerged.txt
