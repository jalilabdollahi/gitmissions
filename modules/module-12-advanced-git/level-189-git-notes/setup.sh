#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main origin.git
git clone -q origin.git ledger-db 2>/dev/null
cd ledger-db
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir migrations
m() { printf -- '-- %s\n%s\n' "$2" "$3" > "migrations/$1"; }
m 0001_create_accounts.sql "accounts" "CREATE TABLE accounts (id INT PRIMARY KEY, owner TEXT);"
printf '# ledger-db\nSQL migrations for the ledger.\n' > README.md
git add -A; ci Paula paula@ledger.dev "2025-02-03T09:00:00" "Start the schema"
m 0002_create_entries.sql "entries" "CREATE TABLE entries (id INT, account_id INT, cents BIGINT);"
git add -A; ci Paula paula@ledger.dev "2025-02-05T09:00:00" "Book keeping tables"
m 0003_index_entries.sql "index" "CREATE INDEX idx_entries_acct ON entries(account_id);"
git add -A; ci Hugo hugo@ledger.dev "2025-02-07T09:00:00" "Speed up account lookups"
m 0001_create_accounts.sql "accounts" "CREATE TABLE accounts (id INT PRIMARY KEY, owner TEXT NOT NULL);"
git add -A; ci Paula paula@ledger.dev "2025-02-10T09:00:00" "Owner must not be empty"
m 0004_audit_trigger.sql "audit" "CREATE TRIGGER audit_entries AFTER INSERT ON entries EXECUTE audit();"
git add -A; ci Hugo hugo@ledger.dev "2025-02-12T09:00:00" "Trail for compliance"
m 0005_add_currency.sql "currency" "ALTER TABLE entries ADD currency CHAR(3) DEFAULT 'EUR';"
git add -A; ci Paula paula@ledger.dev "2025-02-14T09:00:00" "Multi-currency support"
printf '\nRun migrations in numeric order.\n' >> README.md
git add -A; ci Hugo hugo@ledger.dev "2025-02-17T09:00:00" "Readme order hint"
m 0006_backfill_currency.sql "backfill" "UPDATE entries SET currency='EUR' WHERE currency IS NULL;"
git add -A; ci Paula paula@ledger.dev "2025-02-19T09:00:00" "Fill the gaps"
m 0003_index_entries.sql "index" "CREATE INDEX CONCURRENTLY idx_entries_acct ON entries(account_id);"
git add -A; ci Hugo hugo@ledger.dev "2025-02-21T09:00:00" "Index without locking"
m 0007_drop_legacy.sql "cleanup" "DROP TABLE legacy_totals;"
git add -A; ci Paula paula@ledger.dev "2025-02-24T09:00:00" "Retire old totals"
git push -q origin main 2>/dev/null
printf '0001_create_accounts.sql\n0003_index_entries.sql\n0005_add_currency.sql\n0006_backfill_currency.sql\n' > prod-applied.txt
