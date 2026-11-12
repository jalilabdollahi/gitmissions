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

mkdir packages
printf '{"packages": ["alpha", "beta", "gamma"]}\n' > index.json
printf '{"name": "alpha", "version": "1.0.0"}\n' > packages/alpha.json
printf '{"name": "beta", "version": "0.4.0"}\n' > packages/beta.json
printf '{"name": "gamma", "version": "2.1.0"}\n' > packages/gamma.json
git add -A; ci Uma uma@mirror.dev "2025-03-03T09:00:00" "Seed the mirror index"
printf '{"name": "alpha", "version": "1.0.1"}\n' > packages/alpha.json
git add -A; ci Uma uma@mirror.dev "2025-03-05T09:00:00" "alpha 1.0.1"
printf '{"name": "beta", "version": "0.5.0", "deps": ["alpha"]}\n' > packages/beta.json
git add -A; ci Vik vik@mirror.dev "2025-03-07T09:00:00" "beta 0.5.0 depends on alpha"
printf '{"name": "gamma", "version": "2.2.0", "deps": ["alpha", "beta"]}\n' > packages/gamma.json
git add -A; ci Vik vik@mirror.dev "2025-03-10T09:00:00" "gamma 2.2.0"
printf '{"packages": ["alpha", "beta", "gamma", "delta"]}\n' > index.json
git add -A; ci Uma uma@mirror.dev "2025-03-12T09:00:00" "Announce delta in the index"
git branch tmp-scratch HEAD~1
git branch -q -D tmp-scratch
beta=$(git rev-parse HEAD:packages/beta.json)
gamma=$(git rev-parse HEAD:packages/gamma.json)
rm -f ".git/objects/$(printf '%s' "$beta" | cut -c1-2)/$(printf '%s' "$beta" | cut -c3-)"
gp=".git/objects/$(printf '%s' "$gamma" | cut -c1-2)/$(printf '%s' "$gamma" | cut -c3-)"
chmod u+w "$gp"
printf 'this is not a zlib stream\n' > "$gp"
