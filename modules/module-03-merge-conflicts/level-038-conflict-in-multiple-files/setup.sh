#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@claystudio.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@claystudio.example"; }

printf 'name,joined\nIvy,2023-02\nMo,2023-09\n' > members.csv
printf 'slot,member\nTue-am,Ivy\nThu-pm,Mo\n' > kiln-bookings.csv
printf 'item,stock\nstoneware clay,12\nglaze white,4\n' > supplies.csv
printf 'Studio rules: label your work, clean the wheels.\n' > rules.txt
who ivy; git add . && d 2025-02-03T17:00:00; git commit -q -m "Clay studio co-op records"

git switch -q -c weekend-sessions
who mo
printf 'Pia,2025-02\n' >> members.csv
printf 'Sat-am,Pia\n' >> kiln-bookings.csv
printf 'underglaze blue,6\n' >> supplies.csv
printf 'Studio rules: label your work, clean the wheels, no solo kiln loading.\n' > rules.txt
d 2025-02-10T17:00:00; git commit -q -am "Weekend sessions: Pia joins, kiln slot, blue underglaze"

git switch -q main
who ivy
printf 'Raj,2025-02\n' >> members.csv
printf 'Wed-pm,Raj\n' >> kiln-bookings.csv
printf 'kiln wash,3\n' >> supplies.csv
d 2025-02-11T17:00:00; git commit -q -am "Raj joins: kiln slot and kiln wash"
