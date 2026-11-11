#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

c() { # date message
  printf '%s\n' "$2" >> newsletter.md
  GIT_AUTHOR_NAME="Bea" GIT_AUTHOR_EMAIL="bea@greenthumbs.example" GIT_AUTHOR_DATE="$1" \
  GIT_COMMITTER_NAME="Bea" GIT_COMMITTER_EMAIL="bea@greenthumbs.example" GIT_COMMITTER_DATE="$1" \
  git commit -q -am "$2"
}
printf 'Green Thumbs Club newsletter\n' > newsletter.md
git add newsletter.md
GIT_AUTHOR_NAME=Bea GIT_AUTHOR_EMAIL=bea@greenthumbs.example GIT_AUTHOR_DATE=2025-02-10T12:00:00 \
GIT_COMMITTER_NAME=Bea GIT_COMMITTER_EMAIL=bea@greenthumbs.example GIT_COMMITTER_DATE=2025-02-10T12:00:00 \
git commit -q -m "Newsletter template"
c 2025-02-28T23:30:00 "Seed swap announced for the last day of February"
c 2025-03-04T12:00:00 "Tomato sowing tips"
c 2025-03-12T12:00:00 "Compost bin workshop"
c 2025-03-21T12:00:00 "Spring equinox picnic"
c 2025-03-31T12:00:00 "Volunteers needed for allotment 7"
c 2025-04-01T00:30:00 "April fools: the pumpkin that grew overnight"
c 2025-04-15T12:00:00 "Rain barrel discount"
