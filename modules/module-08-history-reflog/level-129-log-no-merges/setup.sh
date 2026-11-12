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
mkdir -p payments
printf '__version__ = "2.3.0"\n' > payments/__init__.py
printf 'def charge(card, cents):\n    return {"ok": True}\n' > payments/client.py
ci Dana "2025-04-07T09:00:00" "Release preparation for 2.3.0"
git tag v2.3.0

git switch -q -c feature/refunds
printf 'def refund(charge_id):\n    return {"refunded": charge_id}\n' > payments/refunds.py
ci Ravi "2025-04-09T10:00:00" "Add refund endpoint"
printf '# Refunds are idempotent\n' >> payments/refunds.py
ci Ravi "2025-04-10T10:00:00" "Make refunds idempotent"
git switch -q main
printf 'TIMEOUT = 12\n' > payments/settings.py
ci Dana "2025-04-11T09:00:00" "Raise default HTTP timeout"
D="2025-04-14T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q --no-ff -m "Merge feature/refunds" feature/refunds

git switch -q -c fix/retry-on-429
printf 'RETRY_STATUSES = (429, 503)\n' >> payments/settings.py
ci Mei "2025-04-15T10:00:00" "Retry on HTTP 429 and 503"
git switch -q main
printf 'Supported Python: 3.9+\n' > SUPPORT.txt
ci Tom "2025-04-16T09:00:00" "Document supported Python versions"
D="2025-04-17T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q --no-ff -m "Merge fix/retry-on-429" fix/retry-on-429
printf 'def redact(card):\n    return "**** " + card[-4:]\n' > payments/redact.py
ci Mei "2025-04-18T09:00:00" "Redact card numbers in logs"
git rev-parse HEAD > .git/gm-tip
