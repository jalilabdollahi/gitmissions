#!/usr/bin/env bash
set -e
git -C ../wt-cache-fix commit -qam "ci: cache dependencies between jobs"
git worktree remove ../wt-cache-fix
git worktree unlock ../wt-release
git worktree remove ../wt-release
git worktree prune
