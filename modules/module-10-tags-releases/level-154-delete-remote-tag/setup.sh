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
printf 'gateway firmware 0.9.8\n' > build.info
ci Dana "2025-08-04T09:00:00" "Release build 0.9.8"
git tag -a v0.9.8 -m "Gateway 0.9.8"
printf 'gateway firmware 1.0.0\n' > build.info
ci Dana "2025-08-11T09:00:00" "Release build 1.0.0"
git tag -a v1.0.0 -m "Gateway 1.0.0"
printf 'gateway firmware 1.0.0-staging\n' > build.info
ci Tom "2025-08-12T09:00:00" "Staging build with unsigned bootloader"
git tag -a v0.9.9 -m "Staging build, do not ship"
git remote add origin ../origin.git
git push -q -u origin main
git push -q origin --tags
