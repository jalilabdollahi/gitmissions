#!/usr/bin/env bash
set -e
export GIT_INDEX_FILE="$PWD/.git/bundle-index"
git read-tree --prefix=api/ api-v3:api
git read-tree --prefix=docs/ docs-v1:docs
tree=$(git write-tree)
unset GIT_INDEX_FILE
rm -f .git/bundle-index
git tag bundle-tree "$tree"
