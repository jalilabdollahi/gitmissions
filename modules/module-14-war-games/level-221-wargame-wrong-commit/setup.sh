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

mkdir dashboards
printf 'CURRENCIES = {"EUR": 2}\n\ndef digits(code):\n    return CURRENCIES[code]\n' > lookup.py
printf 'def parse(text):\n    value = float(text)\n    return round(value * 100)\n' > money.py
printf 'def validate(total):\n    return total is not None\n' > validate.py
git add -A; ci Iris iris@ledger.dev "2025-06-02T09:00:00" "Ledger API 1.9"
git tag v1.9.0
git branch release/1.9
printf '# ledger-api\n' > README.md
git add -A; ci Iris iris@ledger.dev "2025-06-16T09:00:00" "Prepare 2.0 release"
git tag v2.0.0
git branch release/2.0
sed -i.bak 's/{"EUR": 2}/{"EUR": 2, "GBP": 2}/' lookup.py; rm lookup.py.bak
git add -A; ci Iris iris@ledger.dev "2025-06-20T09:00:00" "LEDGER-210: add currency table"
printf 'def _to_cents(value):\n    return round(value * 100)\n\n\ndef parse(text):\n    return _to_cents(float(text))\n' > money.py
git add -A; ci Joss joss@ledger.dev "2025-06-23T09:00:00" "LEDGER-214: refactor money parsing"
m2=$(git rev-parse HEAD)
sed -i.bak 's/return round(value \* 100)/return int(round(value * 100))/' money.py; rm money.py.bak
git add -A; ci Joss joss@ledger.dev "2025-06-24T09:00:00" "LEDGER-219: fix rounding in money parsing"
printf '\n\ndef validate_total(total):\n    return total is not None and total >= 0\n' >> validate.py
git add -A; ci Iris iris@ledger.dev "2025-06-25T09:00:00" "LEDGER-225: reject negative totals"
printf '{"panels": 12}\n' > dashboards/ledger.json
git add -A; ci Joss joss@ledger.dev "2025-06-26T09:00:00" "LEDGER-231: update dashboards"
printf '\n\ndef validate_batch(batch):\n    return len(batch) > 0\n' >> validate.py
git add -A; ci Iris iris@ledger.dev "2025-06-27T09:00:00" "LEDGER-233: guard against empty batch"
sed -i.bak 's/return CURRENCIES\[code\]/return CURRENCIES.get(code, 2)/' lookup.py; rm lookup.py.bak
git add -A; ci Joss joss@ledger.dev "2025-06-30T09:00:00" "LEDGER-240: fix currency lookup crash"
cat > BACKPORT.md <<'EOF'
# Backport plan

release/2.0 (apply in this order, use cherry-pick -x):
1. LEDGER-219 fix rounding in money parsing
2. LEDGER-225 reject negative totals
3. LEDGER-233 guard against empty batch
4. LEDGER-240 fix currency lookup crash

release/1.9 (only this one):
- LEDGER-225 reject negative totals

Do not backport LEDGER-210, LEDGER-214 or LEDGER-231.
EOF
git switch -q release/2.0
for t in LEDGER-233 LEDGER-240 LEDGER-225 LEDGER-219; do
  c=$(git log -1 --format=%H --grep="^$t:" main)
  git cherry-pick -x -X theirs "$c" >/dev/null 2>&1 || { git add -A; GIT_EDITOR=true git cherry-pick --continue >/dev/null 2>&1 || true; }
done
