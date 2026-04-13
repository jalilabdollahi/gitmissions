#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > config.txt <<'EOF'
stable
EOF

git add config.txt

git commit -m "Stable config"

printf 'broken
' > config.txt

git add config.txt

git commit -m "Break config"
