#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

printf 'repo: registry.example/app\n' > promote.yaml
git add -A; ci Quinn quinn@registry.dev "2025-01-06T09:00:00" "Promotion config"
git branch stale/exp-1
printf 'channel: edge\n' >> promote.yaml
git add -A; ci Quinn quinn@registry.dev "2025-01-13T09:00:00" "Add edge channel"
git branch stale/exp-2; git branch release/1.0
git tag -a v1.0 -m "release 1.0"
printf 'channel: stable\n' >> promote.yaml
git add -A; ci Zara zara@registry.dev "2025-01-20T09:00:00" "Add stable channel"
git branch stale/exp-3; git branch release/1.1
git tag -a v1.1 -m "release 1.1"
printf 'signing: cosign\n' >> promote.yaml
git add -A; ci Zara zara@registry.dev "2025-01-27T09:00:00" "Sign promoted images"
git tag v1.2
git pack-refs --all
git switch -q release/1.1
printf 'hotfix: true\n' > HOTFIX.txt
git add -A; ci Zara zara@registry.dev "2025-02-03T09:00:00" "1.1 hotfix marker"
git switch -q main
printf 'retention: 30d\n' >> promote.yaml
git add -A; ci Quinn quinn@registry.dev "2025-02-05T09:00:00" "Retention policy"
