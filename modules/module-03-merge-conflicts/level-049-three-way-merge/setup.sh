#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@choir.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@choir.example"; }

printf 'Amazing Grace\nHallelujah\nSilent Night\n' > repertoire.txt
printf 'Rehearsal: Wednesdays 19:00\n' > schedule.txt
printf 'Choir notes\n' > notes.md
who elin; git add . && d 2025-02-01T19:00:00; git commit -q -m "Choir repertoire and schedule"
printf 'Hallelujah, key of C\n' >> notes.md
git add . && d 2025-02-08T19:00:00; git commit -q -m "Note the key for Hallelujah"
printf 'Rehearsal: Wednesdays 19:00, hall B\n' > schedule.txt
git add . && d 2025-02-12T19:00:00; git commit -q -m "Move rehearsals to hall B"

git switch -q -c spring-concert
who tobias
printf 'Amazing Grace\nHallelujah\nSilent Night\nO Fortuna\nBlackbird\n' > repertoire.txt
d 2025-02-18T19:00:00; git commit -q -am "Add spring concert pieces"
printf 'Spring concert: 12 April\n' > concert.txt
git add . && d 2025-02-20T19:00:00; git commit -q -m "Announce spring concert date"

git switch -q main
who elin
printf 'Rehearsal: Wednesdays 19:00, hall B\nSnacks: rota on the fridge\n' > schedule.txt
d 2025-02-19T19:00:00; git commit -q -am "Add snack rota"
printf 'Choir notes\nHallelujah, key of C\nWarm-up: five minutes humming\n' > notes.md
d 2025-02-21T19:00:00; git commit -q -am "Warm-up routine"
