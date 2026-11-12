#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

c() { # author email date message
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" \
  GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" \
  git commit -q -am "$4"
}
mkdir rules
printf '# Setup\n\nEach player draws 5 cards.\nPlace the board between players.\n' > rules/setup.md
printf '# Scoring\n\nFirst to 20 points wins.\nBonus: +2 for a full set.\n' > rules/scoring.md
git add .
GIT_AUTHOR_NAME=Hana GIT_AUTHOR_EMAIL=hana@dice.example GIT_AUTHOR_DATE=2025-01-05T19:00:00 \
GIT_COMMITTER_NAME=Hana GIT_COMMITTER_EMAIL=hana@dice.example GIT_COMMITTER_DATE=2025-01-05T19:00:00 \
git commit -q -m "First rules draft"

printf '# Setup\n\nEach player draws 5 cards.\nPlace the board between players.\nYoungest player starts.\n' > rules/setup.md
c Hana hana@dice.example 2025-01-12T19:00:00 "Say who starts"
sed -i.bak 's/First to 20 points wins/First to 25 points wins/' rules/scoring.md && rm rules/scoring.md.bak
c Priya priya@dice.example 2025-01-19T21:30:00 "Playtest tweaks"
printf '# Setup\n\nEach player draws 6 cards.\nPlace the board between players.\nYoungest player starts.\n' > rules/setup.md
c Hana hana@dice.example 2025-01-26T19:00:00 "Bigger starting hand"
sed -i.bak 's/First to 25 points wins/First to 30 points wins/' rules/scoring.md && rm rules/scoring.md.bak
c Marcus marcus@dice.example 2025-02-02T15:00:00 "Longer games after feedback"
printf 'Ties are broken by the fewest cards in hand.\n' >> rules/scoring.md
c Hana hana@dice.example 2025-02-09T19:00:00 "Add tiebreak rule"
