#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init --bare remote.git

git clone remote.git local

cd local

git config user.email "player@gitmissions.local"

git config user.name "Player"

cat > README.md <<'EOF'
remote sandbox
EOF

git add README.md

git commit -m "Initial scaffold"

git branch -M main

git push origin main

git -C ../remote.git symbolic-ref HEAD refs/heads/main

cd ..
git clone remote.git seed2
cd seed2
git config user.email "seed@example.com"
git config user.name "Seed"
git switch -c feature/api
printf 'api branch
' > api.txt
git add api.txt
git commit -m "API branch"
git push -u origin feature/api
cd ../local
git fetch origin
