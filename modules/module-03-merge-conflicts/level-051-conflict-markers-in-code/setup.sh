#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@dailybrief.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@dailybrief.example"; }

mkdir docs
cat > docs/ops.md <<'EOF'
# Operations notes
- The CDN contract fixes the production cache TTL at 300 seconds.
- Do not go below it: every shorter value is billed as extra traffic.
EOF
cat > settings.py <<'EOF'
DEBUG = False
CACHE_TTL = 120
ALLOWED_HOSTS = ["brief.example"]
EOF
who nils; git add . && d 2025-07-01T09:00:00; git commit -q -m "Newsletter signup service settings"

git switch -q -c feature/cache
who olga
sed -i.bak 's/^CACHE_TTL = 120/CACHE_TTL = 300/' settings.py && rm settings.py.bak
d 2025-07-03T09:00:00; git commit -q -am "Cache pages for five minutes"

git switch -q main
who nils
sed -i.bak 's/^CACHE_TTL = 120/CACHE_TTL = 60/' settings.py && rm settings.py.bak
d 2025-07-04T09:00:00; git commit -q -am "Shorter cache while testing"

# A hurried merge: the conflict was "resolved" by staging the file with markers inside
git merge feature/cache >/dev/null 2>&1 || true
git add settings.py
d 2025-07-05T09:00:00; git commit -q -m "Merge feature/cache"

who olga
printf 'LOG_LEVEL = "INFO"\n' >> settings.py
d 2025-07-06T09:00:00; git commit -q -am "Set log level to INFO"
