#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

mkdir bin config charts
printf '#!/bin/sh\necho rotating certificates\n' > bin/rotate-certs.sh
printf 'DB_HOST=db.internal\nDB_PORT=5432\n' > config/local.env
printf 'replicas: 1\nimage:\n  tag: dev\n' > charts/values-dev.yaml
printf '# platform-charts\n' > README.md
git add -A; ci Sana sana@platform.dev "2025-04-07T09:00:00" "Charts, rotation script and defaults"
printf 'replicas: 6\nresources:\n  limits:\n    memory: 2Gi\nimage:\n  tag: 3.9.1\n' | git hash-object -w --stdin > .gm-blob
printf 'values-prod blob: %s\n' "$(cat .gm-blob)" > NOTES.txt
rm .gm-blob
printf 'DB_HOST=localhost\nDB_PORT=5432\n' > config/local.env
