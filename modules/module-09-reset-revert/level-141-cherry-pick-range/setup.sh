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
printf 'def batch(payments):\n    return list(payments)\n' > batch_runner.py
ci Dana "2025-09-01T09:00:00" "Payment batch baseline for 3.1"
git branch release/3.1
git switch -q -c feature/sepa-export
mkdir sepa
printf '# SEPA package\n' > sepa/__init__.py
ci Ravi "2025-09-02T10:00:00" "WIP: scaffold sepa package"
printf 'def valid_iban(s):\n    return len(s.replace(" ", "")) >= 15\n' > sepa/iban.py
ci Ravi "2025-09-03T10:00:00" "Add IBAN validation"
printf 'HEADER = "<Document xmlns=\\"urn:iso:std:iso:20022:tech:xsd:pain.001.001.03\\">"\n' > sepa/header.py
ci Ravi "2025-09-04T10:00:00" "Add SEPA XML header"
printf 'def credit_transfer(debtor, creditor, cents):\n    return {"d": debtor, "c": creditor, "amt": cents}\n' > sepa/transfer.py
ci Ravi "2025-09-05T10:00:00" "Add pain.001 credit transfer block"
printf 'BATCH_BOOKING = True  # not validated with the bank\n' > sepa/batch.py
ci Ravi "2025-09-08T10:00:00" "Experimental: batch booking mode"
printf 'def end_to_end_id(ref):\n    return ref[:35]\n' > sepa/e2e.py
ci Ravi "2025-09-09T10:00:00" "Add end-to-end id helper"
git switch -q main
