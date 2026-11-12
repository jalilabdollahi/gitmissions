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
printf '2.0.3\n' > VERSION
printf 'HS6101,2.5\nHS6102,3.1\n' > tariffs.csv
ci Dana "2025-03-03T09:00:00" "Load HS chapter 61 tariffs"
printf 'HS6101,2.5\nHS6102,3.1\nHS6201,4.0\n' > tariffs.csv
ci Dana "2025-03-05T09:00:00" "Load HS chapter 62 tariffs"
printf '2.1.0\n' > VERSION
ci Ravi "2025-03-07T16:30:00" "Wrap up sprint 14"
printf 'HS6201,4.0\nHS6102,3.1\nHS6101,2.5\n' > tariffs.csv
ci Mei "2025-03-10T09:00:00" "Sort tariff table by descending code"
printf '# Changelog\n## 2.1.0\n- Chapter 61 and 62 tariffs\n' > CHANGELOG.md
ci Mei "2025-03-11T09:00:00" "Write changelog for 2.1.0"
printf 'HS6301,5.5\n' >> tariffs.csv
ci Tom "2025-03-12T09:00:00" "Load HS chapter 63 tariffs"
