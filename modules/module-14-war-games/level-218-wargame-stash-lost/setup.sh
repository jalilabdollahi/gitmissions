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

mkdir -p src scripts
printf 'LINT=off\nall:\n\ttrue\n' > Makefile
printf 'local M = {}\nM.WARM_BATCH = 16\nM.WARM_TTL = 60\nreturn M\n' > src/warm.lua
printf 'local DEBUG = false\nreturn { debug = DEBUG }\n' > src/log.lua
printf '# cache-warmer\n' > README.md
git add -A; ci Ravn ravn@cache.dev "2025-11-03T09:00:00" "Cache warmer baseline"
git switch -q -c feature/warmup
printf 'LINT_STRICT=1\n' >> Makefile
git stash push -q -m "lint tweaks"
sed -i.bak 's/WARM_BATCH = 16/WARM_BATCH = 64/' src/warm.lua; rm src/warm.lua.bak
printf -- '-- prewarm hot keys\nreturn {}\n' > scripts/prewarm.lua
git stash push -q -u -m "warmup experiment"
sed -i.bak 's/local DEBUG = false/local DEBUG_SPAM = true/' src/log.lua; rm src/log.lua.bak
git stash push -q -m "debug logging"
git stash clear
sed -i.bak 's/WARM_TTL = 60/WARM_TTL = 90/' src/warm.lua; rm src/warm.lua.bak
git add -A; ci Ravn ravn@cache.dev "2025-11-06T09:00:00" "warm: longer ttl"
