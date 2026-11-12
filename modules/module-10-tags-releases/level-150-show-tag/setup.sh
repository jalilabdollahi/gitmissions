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
printf 'def ship(batch):\n    return len(batch)\n' > shipper.py
ci Dana "2025-04-01T09:00:00" "Audit log shipper base"
printf 'RETRY = 3\n' > settings.py
ci Ravi "2025-04-08T09:00:00" "Retry failed uploads"
GIT_COMMITTER_NAME="Priya Nair" GIT_COMMITTER_EMAIL=priya@example.dev GIT_COMMITTER_DATE="2025-04-09T18:20:00" git tag -a v3.2.0 -m "Hotfix rollup: retries and TLS pinning" -m "Approved by compliance."
printf 'TLS_PIN = "sha256/abc"\n' >> settings.py
ci Ravi "2025-04-10T09:00:00" "Pin TLS certificate"
GIT_COMMITTER_NAME="Tom Walker" GIT_COMMITTER_EMAIL=tom@example.dev GIT_COMMITTER_DATE="2025-04-14T11:00:00" git tag -a v3.2.1 -m "Pin TLS certificate"
printf 'COMPRESS = True\n' >> settings.py
ci Mei "2025-04-16T09:00:00" "Compress log batches"
GIT_COMMITTER_NAME="Mei Tanaka" GIT_COMMITTER_EMAIL=mei@example.dev GIT_COMMITTER_DATE="2025-04-17T10:00:00" git tag -a v3.3.0 -m "Compression support"
