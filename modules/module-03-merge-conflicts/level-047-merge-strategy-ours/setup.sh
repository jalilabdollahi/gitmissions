#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@saltpaper.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@saltpaper.example"; }

mkdir poems
printf 'Salt\nThe sea keeps what it likes.\n' > poems/salt.md
printf 'Paper\nA page is a small field.\n' > poems/paper.md
who ines; git add . && d 2025-01-05T09:00:00; git commit -q -m "First issue of the zine"

git switch -q -c legacy-import
who bot
mkdir -p poems
printf 'salt (draft 1)\nsea sea sea\n' > poems/old-salt-draft.md
printf 'paper (draft 3)\nfield page\n' > poems/old-paper-draft.md
printf 'The sea keeps what it wants.\n' > poems/salt.md
git add . && d 2025-01-20T09:00:00; git commit -q -m "Import drafts from the old blog platform"

git switch -q main
who ines
printf 'Salt\nThe sea keeps what it likes.\nAnd gives back the rest.\n' > poems/salt.md
printf 'Tide\nTwice a day the shore is rewritten.\n' > poems/tide.md
git add . && d 2025-02-01T09:00:00; git commit -q -m "Second issue: expand Salt, add Tide"
