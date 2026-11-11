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
printf 'campaign,goal\nwell-for-all,15000\n' > ledger.csv
ci Dana "2025-02-03T09:00:00" "Initial campaign ledger"

git switch -q -c grace/campaign-export
printf 'def export_csv(rows):\n    return "\\n".join(",".join(map(str, r)) for r in rows)\n' > export.py
ci Grace "2025-02-04T10:00:00" "Export campaigns to CSV"
git switch -q main
printf 'campaign,goal,donors\nwell-for-all,15000,212\n' > ledger.csv
ci Dana "2025-02-05T09:00:00" "Add donor count column"
git switch -q grace/campaign-export
D="2025-02-06T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q -m "Merge branch 'main' into grace/campaign-export" main
git switch -q main
D="2025-02-07T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q --no-ff -m "Merge pull request #12 from grace/campaign-export" grace/campaign-export

git switch -q -c omar/goal-bars
printf 'def bar(pct):\n    return "#" * int(pct / 10)\n' > bars.py
ci Omar "2025-02-10T11:00:00" "Draw goal progress bars"
git switch -q main
printf 'Ledger is updated daily.\n' > NOTES.txt
ci Dana "2025-02-11T09:00:00" "Add notes about update cadence"
D="2025-02-12T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q --no-ff -m "Merge pull request #13 from omar/goal-bars" omar/goal-bars

git switch -q -c lee/currency-fix
printf 'CURRENCY = "EUR"\n' > currency.py
ci Lee "2025-02-14T10:00:00" "Default currency to EUR"
git switch -q main
D="2025-02-17T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q --no-ff -m "Merge pull request #15 from lee/currency-fix" lee/currency-fix
printf 'Hotfix: trim whitespace in goals.\n' >> NOTES.txt
ci Dana "2025-02-18T09:00:00" "Document the whitespace hotfix"
