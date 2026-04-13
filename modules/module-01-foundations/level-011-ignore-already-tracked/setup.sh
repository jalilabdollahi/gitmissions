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

cat > secrets.env <<'EOF'
TOKEN=12345
EOF

git add secrets.env

git commit -m "Add secrets file"
