#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'job: nightly\ncron: "0 2 * * *"\n' > scheduler.yaml
ci Dana "2025-07-07T09:00:00" "ETL scheduler baseline"
git tag -a v1.9.0 -m "Release 1.9.0"
printf 'job: nightly\ncron: "0 3 * * *"\nretries: 2\n' > scheduler.yaml
ci Ravi "2025-07-14T09:00:00" "Move the nightly job to 03:00 and add retries"
git tag -a v2.0.o -m "Release 2.0.0"
printf 'job: weekly-compaction\n' >> scheduler.yaml
ci Mei "2025-07-15T09:00:00" "Add weekly compaction job"
git rev-parse 'v2.0.o^{commit}' > .git/gm-target
