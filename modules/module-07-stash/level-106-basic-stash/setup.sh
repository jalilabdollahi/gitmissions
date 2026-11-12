#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main tablewise
cd tablewise
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'export const book = (t) => t;\n' > reservations.js
printf 'Reservaton confirmed\n' > labels.txt
printf 'let waitlist = [];\n' > waitlist.js
git add . && git commit -q -m "Reservation basics"
printf 'let waitlist = [];\nwaitlist.promote = () => null; // WIP: promote guests\n' > waitlist.js
