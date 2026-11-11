#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Hugo" GIT_AUTHOR_EMAIL="hugo@lakeside-cafe.example"
export GIT_COMMITTER_NAME="Hugo" GIT_COMMITTER_EMAIL="hugo@lakeside-cafe.example"

mkdir ci
cat > ci/pipeline.txt <<'EOF'
# Lakeside Cafe site pipeline
trigger: every new commit on main
steps: build -> upload to hosting
EOF
printf '<h1>Lakeside Cafe</h1>\n<p>Open 8-18, closed Mondays.</p>\n' > index.html
git add .
GIT_AUTHOR_DATE=2025-11-02T09:00:00 GIT_COMMITTER_DATE=2025-11-02T09:00:00 git commit -q -m "Publish cafe site"
printf '<h1>Lakeside Cafe</h1>\n<p>Open 8-18, closed Mondays.</p>\n<p>Try our new pistachio cake.</p>\n' > index.html
git commit -q -am "Announce pistachio cake" --date="2025-11-04T09:00:00"

# Work in progress that must not be part of the redeploy commit
printf 'Draft: winter opening hours\n' > draft-post.md
