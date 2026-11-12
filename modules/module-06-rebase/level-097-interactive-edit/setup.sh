#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main hookpay
cd hookpay
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf '# hookpay\n' > README.md && c "Add readme"
git switch -q -c feature/webhooks
printf 'API_URL = "https://staging.hookpay.dev"\nTIMEOUT = 5\n' > config.py
printf 'def receive(payload):\n    return payload\n' > receiver.py && c "Add webhook receiver"
printf 'import hmac\n\ndef verify(sig, body):\n    return True\n' > signature.py && c "Add signature check"
printf 'QUEUE = []\n' > queue.py && c "Add retry queue"
