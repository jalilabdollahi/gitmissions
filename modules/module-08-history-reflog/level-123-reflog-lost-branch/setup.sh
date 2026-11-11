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
mkdir docs
printf '# Handbook\nWelcome.\n' > docs/index.md
ci Dana "2025-09-01T09:00:00" "Create docs skeleton"
printf '## Flags\n--verbose  more output\n' > docs/cli.md
ci Dana "2025-09-02T09:30:00" "Document CLI flags"
git switch -q -c docs/v2-migration
printf '## Install (v2)\nUse the new installer.\n' > docs/install.md
ci Ravi "2025-09-03T10:00:00" "Port install guide to v2 layout"
printf '/old-install /install 301\n/old-cli /cli 301\n' > docs/redirects.txt
ci Ravi "2025-09-04T10:30:00" "Add redirects for moved pages"
printf '## Flags\n### --verbose\nmore output\n' > docs/cli.md
ci Mei "2025-09-05T15:00:00" "Rewrite API reference headings"
git rev-parse HEAD > .git/gm-orig-tip
git switch -q main
printf 'Version 1.9 is the current release.\n' >> docs/index.md
ci Dana "2025-09-08T09:00:00" "Mention current release on the index page"
git branch -q -D docs/v2-migration
