#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

mkdir data fixtures
printf 'site,batch,seq,value\n' > data/readings.csv
for i in $(seq 1 30); do
  for j in $(seq 1 20); do
    printf 'S%02d,%d,%d,%d\n' $((i % 7 + 1)) "$i" "$j" $((i * j * 7 % 1000)) >> data/readings.csv
  done
  d=$(printf '2025-03-%02dT07:30:00' "$i")
  if [ "$i" -eq 12 ]; then
    for k in $(seq 1 1500); do printf 'frame %d crc=%d payload=%d\n' "$k" $((k * 31 % 997)) $((k * k % 65521)); done > fixtures/sample.log
  fi
  git add -A
  ci Mats mats@readings.dev "$d" "March batch $i"
done
