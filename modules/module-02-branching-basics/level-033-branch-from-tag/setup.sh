#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Pavel" GIT_AUTHOR_EMAIL="pavel@flashlearn.example" GIT_COMMITTER_NAME="Pavel" GIT_COMMITTER_EMAIL="pavel@flashlearn.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

mkdir decks
printf 'bonjour,hello\nmerci,thank you\nau revoir,goodbye\n' > decks/french.csv
git add . && d 2025-03-01T10:00:00; git commit -q -m "French starter deck"
git tag v1.0
printf 'hola,hello\ngracias,thank you\n' > decks/spanish.csv
git add . && d 2025-04-01T10:00:00; git commit -q -m "Add Spanish deck"
printf 'cafe,coffee\n' >> decks/french.csv
d 2025-04-10T10:00:00; git commit -q -am "French: add cafe"
git tag -a v2.0 -m "Release 2.0"
printf 'hallo,hello\ndanke,thank you\n' > decks/german.csv
git add . && d 2025-05-01T10:00:00; git commit -q -m "Start German deck (unreleased)"
sed -i.bak 's/^merci,thank you/merci,thanks/' decks/french.csv && rm decks/french.csv.bak
d 2025-05-05T10:00:00; git commit -q -am "French: simplify merci translation"
