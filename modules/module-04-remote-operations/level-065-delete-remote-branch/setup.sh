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

git switch -c feature/old
printf 'old branch
' > old.txt
git add old.txt
git commit -m "Old branch"
git push -u origin feature/old
git switch main
