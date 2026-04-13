#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init --bare remote.git

git init --bare upstream.git

git clone remote.git local

cd local

git config user.email "player@gitmissions.local"

git config user.name "Player"

cat > README.md <<'EOF'
fork workflow
EOF

git add README.md

git commit -m "Initial scaffold"

git branch -M main

git push origin main

git -C ../remote.git symbolic-ref HEAD refs/heads/main
