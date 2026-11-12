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
printf 'region,population\n' > census.csv
ci Dana "2025-07-01T09:00:00" "Add census table skeleton"
printf 'region,population,respondent_name\nNorth,1204000,A. Hartmann\nSouth,987000,B. Weiss\n' > census.csv
ci Dana "2025-07-02T10:00:00" "Publish census 2024 tables (draft)"
git commit -q --amend -m "Publish census 2024 tables (review)"
printf 'region,population\nNorth,1204000\nSouth,987000\n' > census.csv
git add -A
git commit -q --amend -m "Publish census 2024 tables"
printf '# Data dictionary\nregion: administrative region\npopulation: resident count\n' > DICTIONARY.md
ci Mei "2025-07-03T11:00:00" "Add data dictionary"
