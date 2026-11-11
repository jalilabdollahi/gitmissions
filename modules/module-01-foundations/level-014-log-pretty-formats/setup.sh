#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

c() { # author email date line message
  printf '%s\n' "$4" >> episodes.md
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" \
  GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" \
  git commit -q -am "$5"
}
printf '# Night Shift Radio - show notes\n' > episodes.md
git add episodes.md
GIT_AUTHOR_NAME=Sven GIT_AUTHOR_EMAIL=sven@nightshift.example GIT_AUTHOR_DATE=2025-08-01T22:00:00 \
GIT_COMMITTER_NAME=Sven GIT_COMMITTER_EMAIL=sven@nightshift.example GIT_COMMITTER_DATE=2025-08-01T22:00:00 \
git commit -q -m "Start show notes"
c Sven sven@nightshift.example 2025-08-08T22:00:00 "Ep1: Why we stay up" "Add episode 1 notes"
c Amara amara@nightshift.example 2025-08-15T22:00:00 "Ep2: Bakers at 4am" "Add episode 2 notes"
c Sven sven@nightshift.example 2025-08-22T22:00:00 "Ep3: Taxi drivers" "Add episode 3 notes"
c Amara amara@nightshift.example 2025-08-29T22:00:00 "Ep3: fix guest name spelling" "Correct guest name in ep 3"
c Leo leo@nightshift.example 2025-09-05T22:00:00 "Ep4: Lighthouse keepers" "Add episode 4 notes"
