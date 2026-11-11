#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@reunion.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@reunion.example"; }

mkdir docs
cat > docs/venue.md <<'EOF'
# Old Mill Hall
Address: 4 Mill Lane
Fire marshal certificate: maximum occupancy 45 people
Parking: 12 spaces
EOF
cat > config.py <<'EOF'
EVENT = "Class of 2005 reunion"
MAX_GUESTS = 40
SEND_REMINDERS = True
EOF
who ada; git add . && d 2025-05-02T18:00:00; git commit -q -m "RSVP app for the reunion"

git switch -q -c waiting-list
who bruno
sed -i.bak 's/^MAX_GUESTS = 40/MAX_GUESTS = 50/' config.py && rm config.py.bak
d 2025-05-06T18:00:00; git commit -q -am "Raise guest cap to 50 for the waiting list"

git switch -q main
who ada
sed -i.bak 's/^MAX_GUESTS = 40/MAX_GUESTS = 60/' config.py && rm config.py.bak
d 2025-05-07T18:00:00; git commit -q -am "Raise guest cap to 60, everyone said yes"
