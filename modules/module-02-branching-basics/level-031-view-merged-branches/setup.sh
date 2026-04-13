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

git commit -m "Initial scaffold"

git branch feature/ui

git branch bugfix/login

git checkout -b feature/merged

printf 'merged branch
' > merged.txt

git add merged.txt

git commit -m "Work on merged branch"

git checkout main

git merge feature/merged --no-edit
