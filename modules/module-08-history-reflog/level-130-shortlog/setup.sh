#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
n=0
w() { # name email file
  n=$((n+1))
  printf 'change %s\n' "$n" >> "$3"
  git add -A
  local d; d=$(printf '2025-07-01T10:%02d:00' "$n")
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$d" GIT_COMMITTER_DATE="$d" git commit -q -m "ledger: update $3 ($n)"
}
w "Joy Okafor" joy@ledger.dev core.py
w "Luca Bianchi" luca@ledger.dev core.py
w "Mei Tanaka" mei@ledger.dev reports.py
w "J. Okafor" j.okafor@gmail.com core.py
w "Mei Tanaka" mei@ledger.dev reports.py
w "dependabot[bot]" bot@users.noreply.example.dev deps.txt
w "luca b" lbianchi@old-corp.it core.py
w "Luca Bianchi" luca@ledger.dev reports.py
w "Joy Okafor" joy@ledger.dev core.py
w "Mei Tanaka" mei@ledger.dev reports.py
w "J. Okafor" j.okafor@gmail.com reports.py
w "Luca Bianchi" luca@ledger.dev core.py
w "dependabot[bot]" bot@users.noreply.example.dev deps.txt
w "Mei Tanaka" mei@ledger.dev core.py
w "luca b" lbianchi@old-corp.it reports.py
w "Joy Okafor" joy@ledger.dev reports.py
w "Luca Bianchi" luca@ledger.dev core.py
w "J. Okafor" j.okafor@gmail.com core.py
w "Mei Tanaka" mei@ledger.dev core.py
w "dependabot[bot]" bot@users.noreply.example.dev deps.txt
w "Luca Bianchi" luca@ledger.dev reports.py
w "Joy Okafor" joy@ledger.dev core.py
w "Mei Tanaka" mei@ledger.dev reports.py
git tag v0.9.0
