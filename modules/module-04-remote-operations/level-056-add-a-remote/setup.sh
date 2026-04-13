#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init --bare remote.git

mkdir local

cd local

git init -b main

git config user.email "player@gitmissions.local"

git config user.name "Player"

cat > README.md <<'EOF'
local repo
EOF

git add README.md

git commit -m "Initial scaffold"
