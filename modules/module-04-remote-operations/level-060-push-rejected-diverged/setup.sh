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

printf 'local work
' > local.txt
git add local.txt
git commit -m "Local work"
cd ..
git clone remote.git peer
cd peer
git config user.email "peer@example.com"
git config user.name "Peer"
printf 'peer work
' > peer.txt
git add peer.txt
git commit -m "Peer work"
git push origin main
cd ../local
