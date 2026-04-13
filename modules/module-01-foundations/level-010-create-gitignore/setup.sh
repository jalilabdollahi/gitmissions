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

mkdir -p build

cat > server.log <<'EOF'
noise
EOF

cat > build/output.txt <<'EOF'
artifact
EOF
