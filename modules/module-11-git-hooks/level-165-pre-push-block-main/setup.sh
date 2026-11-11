#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"
git init -q --bare -b main origin.git
git init -q -b main work
cd work
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config core.hooksPath .git/hooks

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'service: billing\nreplicas: 3\nimage: billing:1.8.2\n' > deploy.yaml
ci Dana "2025-05-12T09:00:00" "Billing deployment manifest"
git remote add origin ../origin.git
git push -q -u origin main
git switch -q -c feature/scale-up
printf 'service: billing\nreplicas: 5\nimage: billing:1.8.2\n' > deploy.yaml
ci Ravi "2025-05-13T09:00:00" "Scale billing to five replicas"
