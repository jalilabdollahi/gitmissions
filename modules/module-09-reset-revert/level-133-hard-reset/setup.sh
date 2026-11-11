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
mkdir metrics
printf 'window: 60s\nsinks: [prometheus]\n' > metrics/aggregator.yaml
ci Dana "2025-04-07T09:00:00" "Add aggregator config"
printf 'retention_days: 30\n' >> metrics/aggregator.yaml
ci Dana "2025-04-08T09:00:00" "Set retention to 30 days"
sed -i.bak 's/^window: 60s/window: 5s/' metrics/aggregator.yaml && rm metrics/aggregator.yaml.bak
ci Ravi "2025-04-09T09:00:00" "Switch to experimental 5-second batch window"
printf 'debug: true\n' >> metrics/aggregator.yaml
printf 'ts,value\n1,10\n2,12\n' > scratch-export.csv
