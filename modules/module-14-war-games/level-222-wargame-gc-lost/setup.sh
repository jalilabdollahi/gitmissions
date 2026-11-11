#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main work
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
printf 'def route(lat, lon):\n    return "eu"\n' > router.py
git add -A; ci Brun brun@geo.dev "2025-07-01T09:00:00" "Geo service baseline"
printf 'CACHE = {}\n' > cache.py
git add -A; ci Brun brun@geo.dev "2025-07-08T09:00:00" "Add cache module"
printf '# geo-service\n' > README.md
git add -A; ci Brun brun@geo.dev "2025-07-10T09:00:00" "Readme"
git switch -q -c feature/geo-router
printf 'POLYGONS = {"DE": []}\n' > polygons.py
git add -A; ci Brun brun@geo.dev "2025-07-14T09:00:00" "geo: country polygons"
printf 'def route(lat, lon):\n    return "de" if lat > 47 else "eu"\n' > router.py
git add -A; ci Brun brun@geo.dev "2025-07-15T09:00:00" "geo: route by latitude"
git tag -a v0.9-geo-beta -m "geo beta"
cd "$SANDBOX"
git init -q --bare mirror.git
git -C work push -q ../mirror.git feature/geo-router main v0.9-geo-beta 2>/dev/null
git clone -q work wei-clone 2>/dev/null
cd wei-clone
git switch -q -c feature/tile-cache origin/main
printf 'TILE_SIZE = 256\n' > tiles.py
git add -A; ci Wei wei@geo.dev "2025-07-17T09:00:00" "tiles: fixed tile size"
printf 'TILE_TTL = 3600\n' >> tiles.py
git add -A; ci Wei wei@geo.dev "2025-07-18T09:00:00" "tiles: cache ttl"
cd "$SANDBOX/work"
git fetch -q ../wei-clone feature/tile-cache:feature/tile-cache 2>/dev/null
git switch -q main
git branch -q -D feature/geo-router feature/tile-cache
git tag -d v0.9-geo-beta >/dev/null
git reflog expire --expire=now --all
git gc -q --prune=now
