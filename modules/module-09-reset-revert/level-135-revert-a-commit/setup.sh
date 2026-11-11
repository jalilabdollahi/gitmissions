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
printf 'current_limit_a=2.8\nfan=on\n' > motor.cfg
ci Dana "2025-06-02T09:00:00" "Initial motor controller config"
printf 'current_limit_a=4.2\nfan=on\n' > motor.cfg
ci Ravi "2025-06-03T10:00:00" "Raise motor current limit to 4.2A"
printf 'shutdown_temp_c=85\n' > thermal.cfg
ci Mei "2025-06-04T10:00:00" "Add thermal shutdown threshold"
printf '# Motor controller 1.7\nSee motor.cfg and thermal.cfg.\n' > README.md
ci Tom "2025-06-05T10:00:00" "Document the config files"
git rev-parse HEAD > .git/gm-tip
