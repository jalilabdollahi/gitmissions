#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

mkdir ci-config && cd ci-config
git init -q -b main
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir pipelines
printf 'stages: [build, test]\nbuild:\n  script: make build\n' > pipelines/build.yml
printf 'deploy:\n  script: ./deploy.sh\n' > pipelines/deploy.yml
git add -A; ci Kenji kenji@ci.dev "2025-01-08T09:00:00" "Base build and deploy pipelines"
git worktree add -q -b ci/cache-fix ../wt-cache-fix
git worktree add -q -b ci/old-lint ../wt-old-lint
git worktree add -q -b release-2024 ../wt-release
git worktree add -q -b ci/matrix-build ../wt-active
printf '  cache:\n    key: deps-v2\n    paths: [.m2]\n' >> ../wt-cache-fix/pipelines/build.yml
rm -rf ../wt-old-lint
git worktree lock --reason "on the build laptop" ../wt-release
