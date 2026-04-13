#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > README.md <<'EOF'
# Sandbox
EOF

git add README.md

git commit -m "Initial scaffold"

cat > config.ini <<'EOF'
mode=stable
EOF

git add config.ini

git commit -m "Add config"

printf 'mode=broken
' > config.ini
