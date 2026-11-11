#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main origin.git
git clone -q origin.git work 2>/dev/null
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir limits router
printf 'listen: 8080\nupstream: api\n' > gateway.yaml
git add -A; ci Yuki yuki@gw.dev "2025-07-01T09:00:00" "Gateway baseline"
git push -q origin main 2>/dev/null
git switch -q -c experiment/new-router
for i in 1 2 3 4; do
  printf 'router step %s\n' "$i" > "router/step$i.txt"
  msgs=("router: parse path templates" "router: radix tree" "router: wildcard segments" "router: benchmark harness")
  git add -A; ci Yuki yuki@gw.dev "2025-07-0$((i+1))T09:00:00" "${msgs[$((i-1))]}"
done
git push -q origin experiment/new-router 2>/dev/null
git switch -q main
git switch -q -c feature/rate-limit
printf 'bucket: 100\n' > limits/bucket.yaml
git add -A; ci Player player@gitmissions.local "2025-07-10T09:00:00" "limits: token bucket"
printf 'quota: per-key\n' > limits/quota.yaml
git add -A; ci Player player@gitmissions.local "2025-07-11T09:00:00" "limits: per-key quotas"
printf 'retry_after: 30\n' > limits/retry.yaml
git add -A; ci Player player@gitmissions.local "2025-07-12T09:00:00" "limits: 429 with Retry-After"
git rebase -q experiment/new-router >/dev/null 2>&1
git push -q --force origin feature/rate-limit 2>/dev/null
git branch -q --set-upstream-to=origin/experiment/new-router
git switch -q main
( cd "$SANDBOX"; git clone -q origin.git dev2 2>/dev/null; cd dev2; printf 'listen: 8080\nupstream: api\nhealth: /healthz\n' > gateway.yaml
  git add -A; ci Yuki yuki@gw.dev "2025-07-14T09:00:00" "Hotfix: add health endpoint"; git push -q origin main 2>/dev/null )
git fetch -q origin
git switch -q feature/rate-limit
