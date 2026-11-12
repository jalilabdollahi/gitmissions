#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main rsvpal
cd rsvpal
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'def invite(guest):\n    return guest\n' > invite.py
printf 'GUESTS = []\n' > guests.py
git add . && git commit -q -m "RSVP page basics"
git switch -q -c release/1.2
printf 'def invite(guest):\n    return guest.strip()\n' > invite.py
git commit -q -am "Trim guest names on invite"
git switch -q main
printf 'def invite(guest):\n    return notify(guest)\n' > invite.py
git add invite.py
printf 'GUESTS = []\nWAITLIST = []\n' > guests.py
