#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Tess" GIT_AUTHOR_EMAIL="tess@trailguide.example" GIT_COMMITTER_NAME="Tess" GIT_COMMITTER_EMAIL="tess@trailguide.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

printf 'Ridge Loop - 8 km - moderate\nLake Path - 3 km - easy\n' > trails.txt
git add . && d 2025-07-01T08:00:00; git commit -q -m "Trail list"

git switch -q -c old-layout
printf 'Ridge Loop | 8 km | moderate\nLake Path | 3 km | easy\n' > trails.txt
d 2025-07-02T08:00:00; git commit -q -am "Use column separators"
git switch -q main
git merge -q --no-ff old-layout -m "Merge old-layout"

git switch -q -c typo-fix
sed -i.bak 's/moderate/moderate+/' trails.txt && rm trails.txt.bak
d 2025-07-03T08:00:00; git commit -q -am "Mark Ridge Loop as moderate+"
git switch -q main
git merge -q --ff-only typo-fix

git switch -q -c new-map
printf 'Ridge Loop | 8 km | moderate+\nLake Path | 3 km | easy\nMap: see /img/map-v2.png\n' > trails.txt
d 2025-07-05T08:00:00; git commit -q -am "Link new map (not reviewed yet)"

git switch -q old-layout
