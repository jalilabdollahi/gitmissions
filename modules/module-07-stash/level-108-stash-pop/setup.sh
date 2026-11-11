#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main cardloop
cd cardloop
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'Capital of Franse: Paris\n' > cards.txt
printf 'export const deck = [];\n' > deck.js
git add . && git commit -q -m "Create flashcard deck"
git switch -q -c feature/shuffle
printf 'export function shuffle(d) { return d; }\n' > shuffle.js
git add . && git commit -q -m "Stub shuffle function"
printf 'export function shuffle(d) {\n  return d.sort(() => Math.random() - 0.5);\n}\n' > shuffle.js
git stash push -q -m "WIP shuffle implementation"
git switch -q main
printf 'Capital of France: Paris\n' > cards.txt
git commit -q -am "Fix typo in the France card"
