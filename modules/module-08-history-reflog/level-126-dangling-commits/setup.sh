#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'id,date,amount,category\nE-2001,2025-03-02,48.10,meals\nE-2002,2025-03-04,212.00,travel\nE-2003,2025-03-09,19.99,software\n' > expenses.csv
ci Dana "2025-03-15T09:00:00" "Import March expenses"
printf 'ref,kind,amount\nE-2001,note,0.00\n' > adjustments.csv
ci Dana "2025-03-16T09:00:00" "Add adjustments ledger"
git switch -q -c tmp/one
printf 'E-3310,refund,-45.00\n' >> adjustments.csv
ci Tom "2025-03-17T10:00:00" "Adjust: duplicate taxi charge"
git switch -q main
git switch -q -c tmp/two
printf 'E-4471,refund,-1280.00\n' >> adjustments.csv
ci Ravi "2025-03-18T10:00:00" "Adjust: conference booking cancelled"
git switch -q main
git switch -q -c tmp/three
printf 'E-5120,reclass,0.00\n' >> adjustments.csv
ci Tom "2025-03-19T10:00:00" "Adjust: reclass hotel to travel"
git switch -q main
git branch -q -D tmp/one tmp/two tmp/three
git reflog expire --expire=now --all
