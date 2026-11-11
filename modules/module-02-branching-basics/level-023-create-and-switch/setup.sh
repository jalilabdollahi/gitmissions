#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Oskar" GIT_AUTHOR_EMAIL="oskar@spokecycles.example" GIT_COMMITTER_NAME="Oskar" GIT_COMMITTER_EMAIL="oskar@spokecycles.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

cat > prices.csv <<'EOF'
service,price
Puncture repair,12
Brake adjustment,18
Full service,65
Tyre fitting,20
EOF
printf 'Spoke Cycles - workshop price list. Updated each spring.\n' > README.txt
git add . && d 2025-04-01T09:00:00; git commit -q -m "Spring price list"

# Oskar started editing on main by mistake: winter discount, not yet committed
cat > prices.csv <<'EOF'
service,price
Puncture repair,10
Brake adjustment,15
Full service,55
Tyre fitting,20
EOF
