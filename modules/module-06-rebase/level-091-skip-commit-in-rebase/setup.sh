#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main shelfy
cd shelfy
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'lodash=4.17.15\nexpress=4.17.1\n' > deps.txt && c "List dependencies"
git switch -q -c feature/wishlist
printf 'export const wishlist = [];\n' > wishlist.js && c "Add wishlist page"
printf 'lodash=4.17.20\nexpress=4.17.1\n' > deps.txt && c "Pin lodash 4.17.20"
printf 'assert(Array.isArray(wishlist));\n' > wishlist.test.js && c "Add wishlist tests"
git switch -q main
printf 'lodash=4.17.21\nexpress=4.17.1\n' > deps.txt && c "Upgrade lodash to 4.17.21"
git switch -q feature/wishlist
