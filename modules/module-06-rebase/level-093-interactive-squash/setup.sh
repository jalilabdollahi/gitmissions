#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main gatewise
cd gatewise
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'routes = {}\n' > gateway.py && c "Add route table"
git switch -q -c feature/retry
printf 'ATTEMPTS = 3\n' > retry.py && c "Add retry loop"
printf 'RETRY_ON = 503\n' >> retry.py && c "Handle 503 responses in retry"
printf 'BACKOFF = 2\n' >> retry.py && c "Add retry backoff"
