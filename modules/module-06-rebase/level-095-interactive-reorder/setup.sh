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

git checkout -b feature/rebase

printf 'two
' > two.txt

git add two.txt

git commit -m "Second step"

printf 'one
' > one.txt

git add one.txt

git commit -m "First step"
