#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main cloudcast
cd cloudcast
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
st() { printf '[net]\n# MAX_RETRIES=99 (legacy, ignored)\nMAX_RETRIES=%s\nTIMEOUT=%s\n' "$1" "$2" > settings.ini; }
st 3 10 && c "Initial widget settings"
git tag v1.0
st 6 10 && c "Be more patient on flaky networks"
st 4 10 && c "Reduce battery use from retries"
st 4 8 && c "Shorten timeout"
st 7 8 && c "Retry harder for forecasts"
git tag v1.5
printf 'Retries are configurable.\n' > docs.txt && c "Document retries"
st 2 8 && c "Fail fast in widget"
git tag v2.0
st 2 12 && c "Longer timeout for satellite maps"
