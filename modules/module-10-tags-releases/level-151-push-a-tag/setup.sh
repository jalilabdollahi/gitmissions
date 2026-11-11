#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"
git init -q --bare -b main origin.git
git init -q -b main local
cd local
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'sync every 15 minutes\n' > sync.conf
ci Dana "2025-05-05T09:00:00" "Ledger sync agent baseline"
printf 'timeout 30\n' >> sync.conf
ci Dana "2025-05-06T09:00:00" "Add sync timeout"
git remote add origin ../origin.git
git push -q -u origin main
git rev-parse HEAD > .git/gm-remote-main
printf 'batch 500\n' >> sync.conf
ci Ravi "2025-05-12T09:00:00" "Raise batch size for 1.4"
git tag -a v1.4.0 -m "Release 1.4.0"
printf 'experimental delta sync\n' >> sync.conf
ci Ravi "2025-05-13T09:00:00" "Try delta sync"
git tag v1.5.0-beta
