#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Hanne" GIT_AUTHOR_EMAIL="hanne@campers.example" GIT_COMMITTER_NAME="Hanne" GIT_COMMITTER_EMAIL="hanne@campers.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

cat > packing.txt <<'EOF'
CAMPING TRIP - LAKE WEEKEND
Sleeping bags x3
Tent: 2-person
Water: 6 L
Headlamps x3
EOF
git add . && d 2025-06-02T18:00:00; git commit -q -m "Packing list for the lake weekend"

git switch -q -c group-size
export GIT_AUTHOR_NAME="Jonas" GIT_AUTHOR_EMAIL="jonas@campers.example" GIT_COMMITTER_NAME="Jonas" GIT_COMMITTER_EMAIL="jonas@campers.example"
sed -i.bak 's/^Tent: 2-person/Tent: 3-person/' packing.txt && rm packing.txt.bak
d 2025-06-04T18:00:00; git commit -q -am "Three of us are going: bigger tent"

git switch -q main
export GIT_AUTHOR_NAME="Hanne" GIT_AUTHOR_EMAIL="hanne@campers.example" GIT_COMMITTER_NAME="Hanne" GIT_COMMITTER_EMAIL="hanne@campers.example"
sed -i.bak 's/^Tent: 2-person/Tent: 2-person, 1.8 kg (borrow from Ola)/' packing.txt && rm packing.txt.bak
printf 'Stove: gas, one cartridge\n' >> packing.txt
d 2025-06-05T18:00:00; git commit -q -am "Borrow a light tent, add the stove"
