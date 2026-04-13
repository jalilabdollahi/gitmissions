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

printf 'work
' > work.txt

git add work.txt

git commit -m "bad message"
