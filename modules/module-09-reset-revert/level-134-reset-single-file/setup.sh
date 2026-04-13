#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > app.txt <<'EOF'
one
EOF

cat > debug.txt <<'EOF'
one
EOF

git add app.txt debug.txt

git commit -m "Base commit"

printf 'two
' > app.txt

printf 'two
' > debug.txt

git add app.txt debug.txt
