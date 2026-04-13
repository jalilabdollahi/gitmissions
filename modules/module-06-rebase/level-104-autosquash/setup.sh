#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > app.txt <<'EOF'
value=base
EOF

git add app.txt

git commit -m "Base commit"

git checkout -b feature/rebase

printf 'feature
' > feature.txt

git add feature.txt

git commit -m "Feature change"

printf 'extra1
' > one.txt

git add one.txt

git commit -m "Feature step 1"

printf 'extra2
' > two.txt

git add two.txt

git commit -m "Feature step 2"

git checkout main

printf 'main branch
' > main.txt

git add main.txt

git commit -m "Main change"
