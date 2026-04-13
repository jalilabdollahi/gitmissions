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

cat > app.txt <<'EOF'
version=2
EOF

cat > debug.log <<'EOF'
verbose output
EOF

git add app.txt debug.log
