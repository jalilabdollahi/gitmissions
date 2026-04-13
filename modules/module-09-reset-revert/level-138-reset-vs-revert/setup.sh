#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > change.txt <<'EOF'
one
EOF

git add change.txt

git commit -m "Base commit"

printf 'two
' > change.txt

git add change.txt

git commit -m "Second commit"
