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

printf 'value=rebase
' > app.txt

git add app.txt

git commit -m "Feature change"

git checkout main

printf 'value=main
' > app.txt

git add app.txt

git commit -m "Main change"
