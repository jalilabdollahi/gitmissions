#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
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
mkdir gateway config
printf 'class GatewayClient:\n    def __init__(self, key):\n        self.key = key\n' > gateway/client.py
printf 'GATEWAY_URL=https://pay.example.test\nGATEWAY_KEY=changeme\n' > config/env.example
ci Dana "2025-02-10T09:00:00" "Payment gateway client skeleton"
printf 'import os\n\nKEY = os.environ["GATEWAY_KEY"]\n' > gateway/settings.py
ci Ravi "2025-02-11T09:00:00" "Read the gateway key from the environment"
