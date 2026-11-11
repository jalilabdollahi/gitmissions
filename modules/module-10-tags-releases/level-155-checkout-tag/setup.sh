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
mkdir migrations
printf -- '-- schema_version: 13\nCREATE TABLE invoices (id INT);\n' > schema.sql
ci Dana "2025-09-01T09:00:00" "Baseline invoice schema"
printf -- '-- schema_version: 14\nCREATE TABLE invoices (id INT, paid_at TIMESTAMP);\n' > schema.sql
ci Ravi "2025-09-08T09:00:00" "Add paid_at to invoices"
git tag -a v2.4.1 -m "Billing DB 2.4.1"
printf -- '-- schema_version: 15\nCREATE TABLE invoices (id INT, paid_at TIMESTAMP);\nCREATE TABLE credits (id INT);\n' > schema.sql
ci Mei "2025-09-15T09:00:00" "Add credits table"
printf -- '-- schema_version: 17\nCREATE TABLE invoices (id INT, paid_at TIMESTAMP);\nCREATE TABLE credits (id INT);\nCREATE TABLE refunds (id INT);\n' > schema.sql
ci Mei "2025-09-22T09:00:00" "Add refunds table (schema v17)"
