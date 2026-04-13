#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > app.txt <<'EOF'
base
EOF

git add app.txt

git commit -m "Base commit"

cat > scratch.txt <<'EOF'
untracked
EOF
