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
printf 'import csv\n\ndef load(path):\n    with open(path) as f:\n        return list(csv.DictReader(f))\n' > importer.py
ci Dana "2025-05-05T09:00:00" "Start bank statement importer"
printf 'import csv\n\ndef load(path):\n    with open(path) as f:\n        rows = list(csv.DictReader(f))\n    for r in rows:\n        r["amount"] = float(r.pop("credit") or 0) - float(r.pop("debit") or 0)\n    return rows\n' > importer.py
mkdir fixtures
awk 'BEGIN{print "date,description,debit,credit"; for(i=1;i<=3000;i++) printf "2025-01-%02d,POS PURCHASE %d MERCHANT-%d,%d.%02d,\n", i%28+1, i, i*37%991, i%97, i%100}' > fixtures/statement_jan_full.csv
git add -A
