#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"
git init -q --bare -b main origin.git
git init -q -b main local
cd local
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'report-builder 1.0\n' > suite.txt
ci Dana "2025-06-02T09:00:00" "Suite 1.0"
git tag -a rb-1.0.0 -m "report-builder 1.0.0"
git remote add origin ../origin.git
git push -q -u origin main
git push -q origin rb-1.0.0
printf 'report-builder 1.1\n' > suite.txt
ci Ravi "2025-06-09T09:00:00" "Suite 1.1"
git tag -a rb-1.1.0 -m "report-builder 1.1.0"
printf 'chart-engine 0.4\n' >> suite.txt
ci Ravi "2025-06-10T09:00:00" "Add chart engine"
git tag chart-0.4.0
printf 'export-pdf 0.2\n' >> suite.txt
ci Mei "2025-06-12T09:00:00" "Add PDF export"
git tag -a pdf-0.2.0 -m "export-pdf 0.2.0"
git push -q origin main
