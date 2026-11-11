#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Mara" GIT_AUTHOR_EMAIL="mara@inkwell.example"
export GIT_COMMITTER_NAME="Mara" GIT_COMMITTER_EMAIL="mara@inkwell.example"
export GIT_AUTHOR_DATE="2025-01-20T21:00:00" GIT_COMMITTER_DATE="2025-01-20T21:00:00"

mkdir chapters
printf 'Chapter 1\n\nThe lighthouse had been dark for nine years.\nNobody in Port Alder spoke of it.\n' > chapters/ch01.md
printf 'Chapter 2\n\nEdda climbed the cliff path at dawn.\n' > chapters/ch02.md
printf 'Chapter 3\n\n(outline only)\n' > chapters/ch03.md
printf 'scratch: alternative opening?\n' > scratch.md
git add .
git commit -q -m "Draft chapters 1-3"

printf 'Chapter 1\n\nThe lighthouse had been dark for nine years.\nNobody in Port Alder dared to speak of it.\n' > chapters/ch01.md
printf 'Chapter 2\n\nEdda climbed the cliff path at dawn, a lantern in her fist.\n' > chapters/ch02.md
printf 'scratch: alternative opening? Try starting with the storm.\nWhat if Edda is the keeper?\n' > scratch.md
printf 'Plot holes to fix:\n- who lit the lamp in ch. 2?\n' > notes-private.txt
