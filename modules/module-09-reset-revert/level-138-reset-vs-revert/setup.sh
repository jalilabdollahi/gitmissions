#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"
SANDBOX_ROOT="$PWD"
git init -q --bare -b main origin.git
git init -q -b main work
cd work
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'import math\n\ndef to_cents(amount):\n    return round(amount * 100)\n' > ledger.py
ci Dana "2025-07-07T09:00:00" "Initial loan ledger"
printf 'import math\n\ndef to_cents(amount):\n    return math.floor(amount * 100)\n' > ledger.py
ci Ravi "2025-07-08T10:00:00" "Switch rounding to floor"
git rev-parse HEAD > .git/gm-bad
printf 'def audit(event):\n    print("AUDIT", event)\n' > audit.py
ci Mei "2025-07-09T10:00:00" "Add audit log"
git rev-parse HEAD > .git/gm-orig
git remote add origin ../origin.git
git push -q -u origin main
git switch -q -c feature/fx-fees
printf 'FX_FEE_PCT = {"USD": 0.5, "GBP": 0.4}\n' > fees.py
ci Dana "2025-07-10T10:00:00" "Add FX fee table"
printf 'API_KEY = "test-key-123456"\n' > keys.py
ci Dana "2025-07-10T11:00:00" "WIP: hardcode test API key"
