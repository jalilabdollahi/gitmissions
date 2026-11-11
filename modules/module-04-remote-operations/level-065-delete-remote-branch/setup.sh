#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git seed 2>/dev/null
cd seed
git config user.name "Kofi"
git config user.email "kofi@hirewell.dev"
git config commit.gpgsign false
printf '<h1>Jobs</h1>\n' > index.html
git add . && git commit -q -m "Job listing page"
git push -q origin main
for b in feature/salary-filter feature/saved-searches; do
  git switch -q -c "$b"
  f=$(printf '%s' "$b" | tr '/' '_').txt
  printf '%s\n' "$b" > "$f"
  git add . && git commit -q -m "Implement $b"
  git switch -q main
  git merge -q --no-ff "$b" -m "Merge $b"
done
git switch -q -c release/2025-03
git switch -q main
printf '<h1>Jobs (0)</h1>\n' > index.html
git commit -q -am "Show job count in header"
git switch -q -c feature/remote-badge
printf 'badge\n' > badge.txt
git add . && git commit -q -m "Add remote badge to listings"
git switch -q main
git push -q origin --all

cd "$SANDBOX"
git clone -q origin.git hirewell 2>/dev/null
cd hirewell
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
