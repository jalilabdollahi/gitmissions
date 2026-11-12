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
mkdir -p tools/bin
cat > tools/bin/depsync <<'SH'
#!/bin/sh
# usage: depsync <lockfile>; pretend to install the locked dependencies
printf 'synced %s packages\n' "$(grep -c . "$1")" > .deps-synced
SH
chmod +x tools/bin/depsync
printf 'pandas==2.2.1\nnumpy==1.26.4\n' > requirements.lock
printf 'import pandas\n' > report.py
printf '.deps-synced\n' > .gitignore
ci Dana "2025-07-14T09:00:00" "Reporting job with locked dependencies"
git branch deps-update
git switch -q deps-update
printf 'pandas==2.2.2\nnumpy==1.26.4\nopenpyxl==3.1.2\n' > requirements.lock
ci Ravi "2025-07-15T09:00:00" "Bump pandas and add openpyxl"
git switch -q main
printf '# Reporting job\n' > README.md
ci Dana "2025-07-16T09:00:00" "Add README"
cat > .git/hooks/post-merge <<'HOOK'
#!/bin/sh
# After a merge: if the lock file changed, re-sync the dependencies
if git diff-tree -r --name-only --no-commit-id ORIG_HEAD HEAD | grep -qx 'requirements.lock'; then
  echo "post-merge: requirements.lock changed, syncing dependencies"
  depsync requirements.lock
fi
exit 0
HOOK
chmod +x .git/hooks/post-merge
