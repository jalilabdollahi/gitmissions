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

git init --bare lib.git

git clone lib.git lib-seed

cd lib-seed

git config user.email "player@gitmissions.local"

git config user.name "Player"

cat > lib.txt <<'EOF'
library
EOF

git add lib.txt

git commit -m "Initial library commit"

git branch -M main

git push origin main

git -C ../lib.git symbolic-ref HEAD refs/heads/main

cd ..

rm -rf lib-seed
