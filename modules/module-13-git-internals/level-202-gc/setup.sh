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

mkdir flags
printf 'checkout_v2: on\nbanner: off\n' > flags/defaults.yaml
printf '# flagd\n' > README.md
git add -A; ci Dara dara@flagd.dev "2025-02-03T09:00:00" "Default flags"
printf 'search_boost: on\n' >> flags/defaults.yaml
git add -A; ci Dara dara@flagd.dev "2025-02-05T09:00:00" "Boost search flag"
printf 'retry_budget: 3\n' >> flags/defaults.yaml
git add -A; ci Elan elan@flagd.dev "2025-02-07T09:00:00" "Retry budget flag"
git switch -q -c feature/geo-flags
printf 'geo_parse: iso3166\n' > flags/geo.yaml
git add -A; ci Elan elan@flagd.dev "2025-02-10T09:00:00" "geo: parse country codes"
printf 'geo_allow: [DE, FR, NL]\n' >> flags/geo.yaml
git add -A; ci Elan elan@flagd.dev "2025-02-11T09:00:00" "geo: country allowlist for flags"
git switch -q main
git branch -q -D feature/geo-flags
printf 'experiment: cache\n' >> flags/defaults.yaml
git stash -q
git stash drop -q
printf 'cache_warm: on\n' >> flags/defaults.yaml
git add -A; ci Dara dara@flagd.dev "2025-02-12T09:00:00" "scratch: try a cache"
git reset -q --hard HEAD~1
printf 'banner_v2: on\n' >> flags/defaults.yaml
git add -A; ci Dara dara@flagd.dev "2025-02-14T09:00:00" "Banner v2 flag"
