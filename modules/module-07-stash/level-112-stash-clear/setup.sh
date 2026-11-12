#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main throttlr
cd throttlr
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'TTL = 60\n' > cache.py
printf 'LEVEL = "info"\n' > logging.py
printf 'BURST = 10\nWINDOW = 60\n' > rate_limit.py
printf 'EXPORT = "statsd"\n' > metrics.py
printf 'REGION = "eu"\n' > config.py
git add . && git commit -q -m "Throttlr baseline"
printf 'TTL = 300\n' > cache.py && git stash -q
printf 'LEVEL = "debug"\n' > logging.py && git stash -q
printf 'BURST = 40\nWINDOW = 60\n' > rate_limit.py && git stash -q
printf 'EXPORT = "prometheus"\n' > metrics.py && git stash -q
printf 'REGION = "us"\n' > config.py && git stash -q
