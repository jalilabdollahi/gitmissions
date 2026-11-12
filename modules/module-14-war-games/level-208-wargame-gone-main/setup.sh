#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main ground.git
git clone -q ground.git omar-clone 2>/dev/null
cd omar-clone
git config user.name Omar; git config user.email omar@ground.dev; git config commit.gpgsign false
printf 'pass: AOS 07:10\n' > passes.txt
git add -A; ci Omar omar@ground.dev "2025-03-03T09:00:00" "First pass table"
printf 'pass: AOS 08:50\n' >> passes.txt
git add -A; ci Omar omar@ground.dev "2025-03-05T09:00:00" "Second pass of the day"
git tag -a v1.0 -m "pass planner 1.0"
printf 'pass: AOS 10:30\n' >> passes.txt
git add -A; ci Omar omar@ground.dev "2025-03-07T09:00:00" "Third pass"
git tag -a v1.1 -m "pass planner 1.1"
git push -q origin main --tags 2>/dev/null
cd "$SANDBOX"
git clone -q ground.git maya-clone 2>/dev/null
cd omar-clone
printf 'pass: AOS 12:10\n' >> passes.txt
git add -A; ci Omar omar@ground.dev "2025-03-10T09:00:00" "Midday pass"
git push -q origin main 2>/dev/null
cd "$SANDBOX"
git clone -q ground.git lin-clone 2>/dev/null
cd omar-clone
printf 'pass: AOS 14:00\n' >> passes.txt
git add -A; ci Omar omar@ground.dev "2025-03-12T09:00:00" "Afternoon pass"
git tag -a v1.2 -m "pass planner 1.2"
git push -q origin main --tags 2>/dev/null
cd "$SANDBOX"
git --git-dir=ground.git update-ref -d refs/heads/main
git --git-dir=ground.git tag -d v1.2 >/dev/null
