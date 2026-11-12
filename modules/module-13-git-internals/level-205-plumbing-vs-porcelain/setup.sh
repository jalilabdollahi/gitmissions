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

printf 'local M = {}\nfunction M.load() return true end\nreturn M\n' > plugin.lua
printf '# luamod\nA tiny game plugin.\n' > README.md
git add -A; ci Fenn fenn@luamod.dev "2025-05-05T09:00:00" "Plugin skeleton"
printf 'function M.unload() return true end\n' >> plugin.lua
git add -A; ci Fenn fenn@luamod.dev "2025-05-07T09:00:00" "Add unload hook"
printf '\nSee plugin.lua.\n' >> README.md
git add -A; ci Gus gus@luamod.dev "2025-05-09T09:00:00" "Point readme at the entry file"
