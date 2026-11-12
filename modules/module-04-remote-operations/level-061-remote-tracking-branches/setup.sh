#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git seed 2>/dev/null
cd seed
git config user.name "Lena"
git config user.email "lena@gatepass.dev"
git config commit.gpgsign false
printf 'def issue(event):\n    return "ticket-" + event\n' > tickets.py
git add . && git commit -q -m "Issue tickets"
git push -q origin main
git switch -q -c release/3.1
git push -q origin release/3.1
git switch -q main
git switch -q -c chore/lint-config
printf '[lint]\nmax-line = 100\n' > lint.cfg
git add . && git commit -q -m "Add lint config"
git switch -q main
git merge -q --no-ff chore/lint-config -m "Merge chore/lint-config"
git push -q origin main chore/lint-config
git switch -q -c feature/seat-map
printf 'SEATS = {"A1": "free"}\n' > seats.py
git add . && git commit -q -m "Seat map model"
printf 'SEATS["A2"] = "free"\n' >> seats.py
git add . && git commit -q -m "Seat map rows"
git push -q origin feature/seat-map

cd "$SANDBOX"
git clone -q origin.git gatepass 2>/dev/null
cd gatepass
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

cd "$SANDBOX/seed"
git switch -q main
git switch -q -c hotfix/qr-scan
printf 'QR_VERSION = 3\n' > qr.py
git add . && git commit -q -m "Fix QR scan on older phones"
git push -q origin hotfix/qr-scan
