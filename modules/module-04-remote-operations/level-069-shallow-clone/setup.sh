#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init --bare remote.git

git clone remote.git seed

cd seed

git config user.email "player@gitmissions.local"

git config user.name "Player"

cat > file.txt <<'EOF'
1
EOF

git add file.txt

git commit -m "Commit 1"

printf '2
' > file.txt

git add file.txt

git commit -m "Commit 2"

printf '3
' > file.txt

git add file.txt

git commit -m "Commit 3"

git branch -M main

git push origin main

git -C ../remote.git symbolic-ref HEAD refs/heads/main

cd ..

rm -rf seed
