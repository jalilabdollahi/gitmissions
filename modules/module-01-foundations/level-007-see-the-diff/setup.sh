#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Ines" GIT_AUTHOR_EMAIL="ines@home.example"
export GIT_COMMITTER_NAME="Ines" GIT_COMMITTER_EMAIL="ines@home.example"
export GIT_AUTHOR_DATE="2025-04-01T20:00:00" GIT_COMMITTER_DATE="2025-04-01T20:00:00"

cat > budget.csv <<'EOF'
category,planned,actual
rent,1200,1200
groceries,450,431
transport,90,102
fun,120,98
savings,300,300
EOF
git add budget.csv
git commit -q -m "April budget"

# staged change
sed -i.bak 's/^groceries,450,431/groceries,450,468/' budget.csv && rm budget.csv.bak
git add budget.csv
# further unstaged change in the same file
sed -i.bak 's/^fun,120,98/fun,120,141/' budget.csv && rm budget.csv.bak
sed -i.bak 's/^savings,300,300/savings,300,250/' budget.csv && rm budget.csv.bak
