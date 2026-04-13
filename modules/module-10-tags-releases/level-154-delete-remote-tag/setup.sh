#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init --bare remote.git

git clone remote.git local

cd local

git config user.email "player@gitmissions.local"

git config user.name "Player"

cat > app.txt <<'EOF'
v1
EOF

git add app.txt

git commit -m "Release commit"

git tag v0.9

git branch -M main

git push origin main

git -C ../remote.git symbolic-ref HEAD refs/heads/main

git push origin v0.9
