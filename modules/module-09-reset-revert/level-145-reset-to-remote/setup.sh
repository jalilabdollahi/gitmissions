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
printf 'SYMBOLS = ["ACME", "GLOBEX"]\nMAX_POSITION = 1000\n' > bot.cfg
ci Dana "2025-12-01T09:00:00" "Trading bot base config"
git remote add origin ../origin.git
git push -q -u origin main
cd ..
git clone -q origin.git teammate
cd teammate
git config user.name "Omar"
git config user.email "omar@example.dev"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'STOP_LOSS_PCT = 2.5\n' > risk.cfg
ci Omar "2025-12-02T10:00:00" "Add stop-loss setting"
printf 'MAX_POSITION = 750\n' > limits.cfg
ci Omar "2025-12-03T10:00:00" "Lower max position size"
git push -q origin main
cd ../local
printf 'print("tick", price)\n' > debug_ticks.py
ci Dana "2025-12-02T09:00:00" "Test dump of live ticks"
printf 'SYMBOLS = ["ACME", "GLOBEX", "TEST1"]\n' > bot.cfg
ci Dana "2025-12-02T09:30:00" "Temporarily trade a test symbol"
