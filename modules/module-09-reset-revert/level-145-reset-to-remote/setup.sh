#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init --bare remote.git

git clone remote.git local

cd local

git config user.email "player@gitmissions.local"

git config user.name "Player"

cat > base.txt <<'EOF'
base
EOF

git add base.txt

git commit -m "Base commit"

git branch -M main

git push origin main

git -C ../remote.git symbolic-ref HEAD refs/heads/main

cat > local.txt <<'EOF'
local only
EOF

git add local.txt

git commit -m "Local only commit"
