#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Rosa" GIT_AUTHOR_EMAIL="rosa@openmic.example" GIT_COMMITTER_NAME="Rosa" GIT_COMMITTER_EMAIL="rosa@openmic.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

printf 'OPEN MIC NIGHT\nEvery second Friday, 20:00, The Blue Door\n' > poster.txt
printf 'Sign-up: ask at the bar\n' > info.txt
git add .
d 2025-03-07T12:00:00; git commit -q -m "Poster and info for open mic night"
printf 'Sign-up: ask at the bar\nDoors open 19:30\n' > info.txt
git add . && d 2025-03-09T12:00:00; git commit -q -m "Add doors time"

git switch -q -c poster-redesign
printf 'OPEN MIC NIGHT *** NEW LOOK ***\nEvery second Friday, 20:00, The Blue Door\n' > poster.txt
d 2025-03-12T12:00:00; git commit -q -am "Try a bolder poster"
