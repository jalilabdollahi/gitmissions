#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@orchestra.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@orchestra.example"; }

cat > programme.md <<'EOF'
# Season programme
Autumn: Brahms Symphony 2
Winter: carols evening
Spring: Dvorak Symphony 9
EOF
printf 'Rehearsals: Mondays 19:30\n' > rehearsals.md
who clara; git add . && d 2025-08-01T10:00:00; git commit -q -m "Orchestra season programme"

git switch -q -c feature/summer-programme
who dario
sed -i.bak 's/^Winter: carols evening/Winter: carols evening with brass guests/' programme.md && rm programme.md.bak
d 2025-08-05T10:00:00; git commit -q -am "Invite brass guests to the carols evening"
printf 'Summer: Gala in the park\n' >> programme.md
d 2025-08-06T10:00:00; git commit -q -am "Add summer concert programme"

git switch -q main
who clara
printf 'Rehearsals: Mondays 19:30, hall B\n' > rehearsals.md
d 2025-08-07T10:00:00; git commit -q -am "Rehearsals move to hall B"
sed -i.bak 's/^Winter: carols evening/Winter: carols evening (sold out, add a second night)/' programme.md && rm programme.md.bak
d 2025-08-08T10:00:00; git commit -q -am "Update carols evening: second night"
