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

git checkout -b feature/old

printf 'done
' > done.txt

git add done.txt

git commit -m "Complete work"

git checkout main

git merge feature/old --no-edit
