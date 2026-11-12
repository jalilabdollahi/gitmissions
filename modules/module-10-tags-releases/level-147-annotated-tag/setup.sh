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
mkdir -p feed
printf 'def latest(symbol):\n    raise NotImplementedError\n' > feed/client.py
ci Dana "2025-02-03T09:00:00" "Price feed client skeleton"
printf 'def latest(symbol):\n    return {"symbol": symbol, "price": 0.0}\n' > feed/client.py
ci Dana "2025-02-05T09:00:00" "Return quotes from latest()"
printf '# Price feed SDK\nStable API: feed.client.latest(symbol)\n' > README.md
ci Mei "2025-02-07T09:00:00" "Document the stable API"
