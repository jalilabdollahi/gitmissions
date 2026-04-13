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

git checkout -b feature/rebase

printf 'bad
' > bad.txt

git add bad.txt

git commit -m "Broken commit"

printf 'good
' > good.txt

git add good.txt

git commit -m "Good commit"

git checkout main

printf 'main
' > main.txt

git add main.txt

git commit -m "Main update"
