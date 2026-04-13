#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > base.txt <<'EOF'
base
EOF

git add base.txt

git commit -m "Base commit"

cat > recovered.txt <<'EOF'
rescued
EOF

git add recovered.txt

git commit -m "Recovery point"

git reset --hard HEAD~1
