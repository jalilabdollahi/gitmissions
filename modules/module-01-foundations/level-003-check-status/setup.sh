#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Noor" GIT_AUTHOR_EMAIL="noor@chess-club.example"
export GIT_COMMITTER_NAME="Noor" GIT_COMMITTER_EMAIL="noor@chess-club.example"
export GIT_AUTHOR_DATE="2025-02-10T18:00:00" GIT_COMMITTER_DATE="2025-02-10T18:00:00"

printf 'Tuesday 19:00 - Open play\nThursday 19:00 - Blitz night\n' > schedule.txt
printf 'Noor: boards\nTheo: clocks\n' > equipment.txt
printf 'Welcome to the Riverside Chess Club.\n' > flyer.md
printf '# Tournament rules\n1. Touch-move applies.\n' > rules.md
printf 'Tea 12\nBiscuits 8\n' > snacks.txt
git add .
git commit -q -m "Set up club planner"

# Now create a messy working tree
printf 'Tuesday 19:00 - Open play\nThursday 19:00 - Blitz night\nSaturday 14:00 - Junior lessons\n' > schedule.txt
printf '# Tournament rules\n1. Touch-move applies.\n2. Phones off.\n' > rules.md
git add schedule.txt rules.md
printf 'Welcome to the Riverside Chess Club.\nNew members get a free first month.\n' > flyer.md
rm snacks.txt
printf 'Spring tournament budget: 120\n' > budget-draft.txt
printf 'Ask the library about Saturday room\n' > todo.txt
