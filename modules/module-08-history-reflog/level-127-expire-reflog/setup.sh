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
mkdir -p etl
printf 'pipeline: nightly-load\nsource: warehouse\n' > etl/pipeline.yaml
ci Dana "2025-11-03T09:00:00" "Add pipeline config"
printf 'schedule: "0 2 * * *"\n' >> etl/pipeline.yaml
ci Dana "2025-11-04T09:00:00" "Set nightly schedule"
git branch legacy
printf 'retries: 3\nbackoff: exponential\n' >> etl/pipeline.yaml
ci Ravi "2025-11-05T09:00:00" "Add retry policy"
mkdir -p dump
awk 'BEGIN{for(i=0;i<60000;i++) printf "{\"event_id\":%d,\"payload\":\"%x%x\"}\n", i, i*7919, i*104729}' > dump/raw_events.ndjson
ci Ravi "2025-11-06T09:00:00" "Add raw event dump for debugging"
git rev-parse HEAD > .git/gm-dump-sha
git rev-parse HEAD:dump/raw_events.ndjson >> .git/gm-dump-sha
git reset -q --hard HEAD~1
