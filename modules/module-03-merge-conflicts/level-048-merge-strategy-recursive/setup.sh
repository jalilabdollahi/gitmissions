#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > app.txt <<'EOF'
base
EOF

git add app.txt

git commit -m "Base commit"

git checkout -b feature/merge

printf 'feature-side
' > app.txt

git add app.txt

git commit -m "Feature side"

git checkout main

printf 'main-side
' > app.txt

git add app.txt

git commit -m "Main side"
