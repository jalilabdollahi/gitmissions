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
seed
EOF

git add README.md

git commit -m "Initial scaffold"

git branch -M main

git push origin main

git -C ../remote.git symbolic-ref HEAD refs/heads/main

git checkout -b feature/ui

cat > ui.txt <<'EOF'
remote ui
EOF

git add ui.txt

git commit -m "Add remote branch"

git push -u origin feature/ui

cd ..

git clone remote.git local

cd local

git config user.email "player@gitmissions.local"

git config user.name "Player"

git branch feature/ui origin/feature/ui
