#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Nadia" GIT_AUTHOR_EMAIL="nadia@bikeshare.example" GIT_COMMITTER_NAME="Nadia" GIT_COMMITTER_EMAIL="nadia@bikeshare.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

cat > stations.csv <<'EOF'
id,name,lat,lon
15,Central Square,53.3498,-6.2603
16,University Gate,53.3438,-6.2546
17,Harbor Gate,53.3541,-6.2292
EOF
git add . && d 2025-09-02T09:00:00; git commit -q -m "Import stations from city feed"
printf 'format: csv\nupdated: 2025-09\n' > data-notes.txt
git add . && d 2025-09-10T09:00:00; git commit -q -m "Ship v1.4 data release"
printf '18,Library Corner,53.3450,-6.2700\n' >> stations.csv
d 2025-09-18T09:00:00; git commit -q -am "Add station 18"
printf '19,Park Entrance,53.3612,-6.2511\n' >> stations.csv
d 2025-09-25T09:00:00; git commit -q -am "Add station 19"
