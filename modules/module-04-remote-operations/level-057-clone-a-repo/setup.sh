#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init --bare remote.git

git clone remote.git seed

cd seed

git config user.email "player@gitmissions.local"

git config user.name "Player"

cat > README.md <<'EOF'
clone me
EOF

git add README.md

git commit -m "Initial scaffold"

git branch -M main

git push origin main

git -C ../remote.git symbolic-ref HEAD refs/heads/main

cd ..

rm -rf seed
