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

git checkout -b old-base

printf 'old base
' > old.txt

git add old.txt

git commit -m "Old base work"

git checkout -b feature/rebase

printf 'feature
' > feature.txt

git add feature.txt

git commit -m "Feature work"

git checkout main

printf 'main
' > main.txt

git add main.txt

git commit -m "Main work"
