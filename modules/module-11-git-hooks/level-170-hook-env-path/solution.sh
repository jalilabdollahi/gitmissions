#!/usr/bin/env bash
set -e
sed -i.bak 's#^  depsync requirements.lock#  "$(git rev-parse --show-toplevel)/tools/bin/depsync" requirements.lock#' .git/hooks/post-merge && rm .git/hooks/post-merge.bak
