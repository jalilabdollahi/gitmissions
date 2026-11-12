#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config core.hooksPath .git/hooks

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
mkdir pricing
cat > pricing/blackscholes.py <<'PY'
import math


def d1(s, k, t, r, sigma):
    return (math.log(s / k) + (r + sigma ** 2 / 2) * t) / (sigma * math.sqrt(t))


def call_price(s, k, t, r, sigma):
    breakpoint()  # legacy: left in by the previous maintainer
    x = d1(s, k, t, r, sigma)
    return s * x
PY
printf '# Options pricing\nNotes on pdb usage live in the wiki.\n' > NOTES.md
ci Dana "2025-03-17T09:00:00" "Black-Scholes call pricing"
