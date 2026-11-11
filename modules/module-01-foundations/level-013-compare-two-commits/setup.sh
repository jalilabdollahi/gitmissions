#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Elena" GIT_AUTHOR_EMAIL="elena@weddings.example"
export GIT_COMMITTER_NAME="Elena" GIT_COMMITTER_EMAIL="elena@weddings.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

printf 'Anna,vegetarian\nBen,none\nCarla,vegan\n' > guests.csv
printf 'Starter: beet salad\nMain: roast chicken\nDessert: lemon tart\n' > menu.txt
printf 'Round tables of 8\n' > seating.md
printf 'Sat 14:00 ceremony\n' > timeline.txt
git add .
d 2025-05-01T10:00:00; git commit -q -m "Plan wedding for 120 guests"

printf 'Anna,vegetarian\nBen,none\nCarla,vegan\nDavid,nuts\n' > guests.csv
d 2025-05-03T10:00:00; git commit -q -am "Add David"

printf 'Round tables of 10\n' > seating.md
d 2025-05-05T10:00:00; git commit -q -am "Try bigger tables"

printf 'Starter: beet salad\nMain: roast chicken\nDessert: lemon tart\nCheese board\n' > menu.txt
printf 'Sat 14:00 ceremony\nSat 16:00 photos\n' > timeline.txt
d 2025-05-08T10:00:00; git commit -q -am "Tasting day updates"

printf 'Round tables of 8\n' > seating.md
d 2025-05-10T10:00:00; git commit -q -am "Back to tables of 8"

printf 'Anna,vegetarian\nBen,none\nCarla,vegan\nDavid,nuts\nEmil,none\n' > guests.csv
d 2025-05-12T10:00:00; git commit -q -am "Add Emil"

printf 'Mon: call florist\n' > todo.txt
git add todo.txt
d 2025-05-14T10:00:00; git commit -q -m "Add todo list"
