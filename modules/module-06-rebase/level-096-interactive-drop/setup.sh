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

printf 'debug
' > debug.txt

git add debug.txt

git commit -m "Debug print"

printf 'final
' > final.txt

git add final.txt

git commit -m "Final work"
