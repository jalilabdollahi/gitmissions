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

mkdir api docs
printf 'class Client:\n    version = 3\n' > api/client.py
printf 'class PaymentError(Exception): pass\n' > api/errors.py
git add -A; ci Rin rin@paysdk.dev "2025-03-03T10:00:00" "Release api v3"
git tag api-v3
printf '# Payments SDK\nUse Client().charge()\n' > docs/index.md
printf '# Quickstart\npip install paysdk\n' > docs/quickstart.md
git add -A; ci Rin rin@paysdk.dev "2025-03-10T10:00:00" "Docs release 1"
git tag docs-v1
printf 'class Client:\n    version = 4\n    async def charge(self): ...\n' > api/client.py
printf 'import asyncio\n' > api/aio.py
git add -A; ci Theo theo@paysdk.dev "2025-04-01T10:00:00" "Rewrite the client for api v4"
printf '# Payments SDK\nUse Client().charge() or await it.\n' > docs/index.md
git add -A; ci Theo theo@paysdk.dev "2025-04-08T10:00:00" "Docs revision 2"
