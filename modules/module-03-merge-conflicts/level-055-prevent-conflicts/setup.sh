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

git checkout -b feature/prevent

cat > feature.txt <<'EOF'
feature
EOF

git add feature.txt

git commit -m "Feature work"

git checkout main

cat > main.txt <<'EOF'
main
EOF

git add main.txt

git commit -m "Main work"

git checkout feature/prevent
