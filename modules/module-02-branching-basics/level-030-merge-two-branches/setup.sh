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

git commit -m "Initial scaffold"

git checkout -b feature/api

cat > api.txt <<'EOF'
api work
EOF

git add api.txt

git commit -m "Add API work"

git checkout main

cat > main.txt <<'EOF'
main work
EOF

git add main.txt

git commit -m "Add main work"
