#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main pingly
cd pingly
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'rate: 100\n' > limits.yaml && c "Initial limits"
git branch release/3.9
printf 'channels: [email]\n' > channels.yaml && c "Add email channel"
git switch -q -c release/4.0
printf 'channels: [email, sms]\n' > channels.yaml && c "Add sms channel"
printf 'channels: [email, sms, push]\n' > channels.yaml && c "Add push channel"
git switch -q --detach HEAD~2
printf 'rate: 9999\n' > limits.yaml
