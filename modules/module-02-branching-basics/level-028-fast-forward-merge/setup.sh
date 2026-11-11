#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Farah" GIT_AUTHOR_EMAIL="farah@mealprep.example" GIT_COMMITTER_NAME="Farah" GIT_COMMITTER_EMAIL="farah@mealprep.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

printf 'MON: pasta\nTUE: curry\nWED: salad\n' > week-plan.txt
git add . && d 2025-09-01T18:00:00; git commit -q -m "Week plan"
printf 'olive oil\nrice\n' > pantry.txt
git add . && d 2025-09-03T18:00:00; git commit -q -m "Pantry list"

git switch -q -c add-lunch-ideas
printf 'LUNCH: soup, wraps, leftovers\n' > lunch.txt
git add . && d 2025-09-05T18:00:00; git commit -q -m "Lunch ideas"
printf 'LUNCH: soup, wraps, leftovers\nBOX: bento Fridays\n' > lunch.txt
d 2025-09-06T18:00:00; git commit -q -am "Add bento Fridays"
git switch -q main
