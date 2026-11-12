#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

mkdir workspace
git init -q --bare -b main streamlane.git
git clone -q streamlane.git seed 2>/dev/null
cd seed
git config user.name "Vik"
git config user.email "vik@streamlane.dev"
git config commit.gpgsign false
for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14; do
  printf 'bitrate=%s\n' "$((i * 150))" > encoder.conf
  git add . && git commit -q -m "Tune encoder profile $i"
done
git push -q origin main
cd ..
rm -rf seed
