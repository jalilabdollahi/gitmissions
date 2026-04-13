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

git checkout -b feature/a

cat > a.txt <<'EOF'
a
EOF

git add a.txt

git commit -m "Add a"

git checkout main

git checkout -b feature/b

cat > b.txt <<'EOF'
b
EOF

git add b.txt

git commit -m "Add b"

git checkout main

git checkout -b feature/c

cat > c.txt <<'EOF'
c
EOF

git add c.txt

git commit -m "Add c"

git checkout main
