#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > app.txt <<'EOF'
v1
EOF

git add app.txt

git commit -m "Initial release"

git tag v1.0

printf 'v2
' > app.txt

git add app.txt

git commit -m "Next release"
