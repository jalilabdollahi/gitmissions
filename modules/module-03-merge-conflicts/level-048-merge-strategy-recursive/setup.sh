#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@harbourbrass.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@harbourbrass.example"; }

cat > setlist.csv <<'EOF'
order,song,minutes
1,Opening Fanfare,5
2,River Song,4
3,Night Train,6
4,Slow Dance,5
5,Marching Medley,8
6,Encore Blues,7
EOF
who gus; git add . && d 2025-03-01T20:00:00; git commit -q -m "Setlist for the harbour festival"

git switch -q -c acoustic-night
who pia
sed -i.bak -e 's/^2,River Song,4/2,River Song (acoustic),4/' -e 's/^4,Slow Dance,5/4,Slow Dance,3/' setlist.csv && rm setlist.csv.bak
d 2025-03-05T20:00:00; git commit -q -am "Acoustic version of River Song, shorter Slow Dance"

git switch -q main
who gus
sed -i.bak -e 's/^2,River Song,4/2,River Song (extended),6/' -e 's/^6,Encore Blues,7/6,Encore Blues,9/' setlist.csv && rm setlist.csv.bak
d 2025-03-06T20:00:00; git commit -q -am "Extended River Song, longer encore"
