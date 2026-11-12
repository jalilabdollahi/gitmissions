#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

mkdir platform && cd platform
git init -q -b main
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
for s in auth billing catalog checkout search notify reports gateway; do
  mkdir -p "services/$s"; printf 'package main\n// service %s\nfunc main() {}\n' "$s" > "services/$s/main.go"
done
for l in money tax rates logging http ids; do
  mkdir -p "libs/$l"; printf 'package %s\n' "$l" > "libs/$l/$l.go"
done
printf 'libs/money\nlibs/tax\n' > services/billing/deps.txt
printf 'libs/rates\n' > libs/tax/deps.txt
printf 'libs/ids\n' > libs/rates/deps.txt
printf 'libs/logging\n' > services/auth/deps.txt
printf 'build:\n\tgo build ./...\n' > Makefile
git add -A; ci Wen wen@mono.dev "2025-06-02T09:00:00" "Import services and libraries"
printf 'package money\n// round half even\n' > libs/money/money.go
git add -A; ci Wen wen@mono.dev "2025-06-09T09:00:00" "money: banker's rounding"
