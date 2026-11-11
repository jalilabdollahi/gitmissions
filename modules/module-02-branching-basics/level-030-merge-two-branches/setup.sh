#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_COMMITTER_NAME="Dungeon Master" GIT_COMMITTER_EMAIL="dm@campaign.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
a() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@campaign.example"; }

mkdir npcs locations sessions
cat > world.md <<'EOF'
# The Saltmarch
Founded: Year 112
Patron deity: the Tidemother
Ruler: Lady Orsolya
Currency: silver marks
Danger level: low
EOF
printf 'Mira - harbour master, suspicious of strangers.\n' > npcs/mira.md
printf 'Harbour: docks, fish market, lighthouse.\n' > locations/harbor.md
a dm; git add . && d 2025-01-10T19:00:00; git commit -q -m "Campaign wiki: the Saltmarch"

git switch -q -c session-12-recap
a priya
printf '# Session 12\nThe party freed Mira from the smugglers.\n' > sessions/12.md
git add . && d 2025-01-14T20:00:00; git commit -q -m "Write session 12 recap"
printf 'Harbour: docks, fish market, lighthouse.\nThe lighthouse hides a smuggler tunnel.\n' > locations/harbor.md
d 2025-01-15T20:00:00; git commit -q -am "Reveal the lighthouse tunnel"
sed -i.bak 's/^Danger level: low/Danger level: high/' world.md && rm world.md.bak
d 2025-01-16T20:00:00; git commit -q -am "Raise the danger level after session 12"

git switch -q main
a marcus
printf 'Mira - harbour master, grateful to the party.\nShe sells maps for 5 silver marks.\n' > npcs/mira.md
d 2025-01-17T18:00:00; git commit -q -am "Update Mira after the rescue"
sed -i.bak 's/^Patron deity: the Tidemother/Patron deity: the Tidemother and the Lantern King/' world.md && rm world.md.bak
d 2025-01-18T18:00:00; git commit -q -am "Add second deity"
