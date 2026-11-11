#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Camille" GIT_AUTHOR_EMAIL="camille@wanderlog.example" GIT_COMMITTER_NAME="Camille" GIT_COMMITTER_EMAIL="camille@wanderlog.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

mkdir _posts
cat > _config.yml <<'EOF'
title: Wanderlog
timezone: UTC
posts_per_page: 5
EOF
printf '# Lisbon in three days\n' > _posts/2025-04-02-lisbon.md
printf '# Wanderlog\n' > index.md
git add . && d 2025-04-02T08:00:00; git commit -q -m "Travel blog with Lisbon post"
printf '# Porto food guide\n' > _posts/2025-04-20-porto.md
git add . && d 2025-04-20T08:00:00; git commit -q -m "Add Porto food guide"

git switch -q -c staging
cat > _config.yml <<'EOF'
title: Wanderlog - slow travel stories
timezone: Europe/Lisbon
posts_per_page: 8
EOF
printf '# Draft: a week in the Azores\nTODO\n' > _posts/draft-azores.md
git add . && d 2025-05-01T08:00:00; git commit -q -m "Staging: new config and Azores draft"
printf '# Draft: Madeira hikes\nTODO\n' > _posts/draft-madeira.md
git add . && d 2025-05-03T08:00:00; git commit -q -m "Staging: Madeira draft"
git switch -q main
