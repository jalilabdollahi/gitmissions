#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main origin.git
git clone -q origin.git work 2>/dev/null
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
printf '# ledger-sync\nPipeline that syncs ledgers between regions.\n' > README.md
git add -A; ci Noor noor@ledger.dev "2025-08-01T09:00:00" "Ledger project skeleton"
git push -q origin main 2>/dev/null
git switch -q -c feature/ledger-sync
printf 'CREATE TABLE sync_state (region TEXT, cursor BIGINT);\n' > schema.sql
git add -A; ci Player player@gitmissions.local "2025-08-04T09:00:00" "Add sync schema"
printf 'def load(rows):\n    retun rows\n' > importer.py
git add -A; ci Player player@gitmissions.local "2025-08-05T09:00:00" "Add importer"
printf 'def backoff(n):\n    return min(2 ** n, 60)\n' > retry.py
git add -A; ci Player player@gitmissions.local "2025-08-06T09:00:00" "Add retry with backoff"
printf 'def load(rows):\n    return rows\n' > importer.py
git add -A; ci Player player@gitmissions.local "2025-08-07T09:00:00" "fixup! Add importer"
printf 'def dump(rows):\n    return list(rows)\n' > exporter.py
git add -A; ci Player player@gitmissions.local "2025-08-08T09:00:00" "Add exporter"
git push -q origin feature/ledger-sync 2>/dev/null
GIT_SEQUENCE_EDITOR="sed -i.bak '3s/^pick/fixup/'" git rebase -q -i main >/dev/null 2>&1
