#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@cycleclub.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@cycleclub.example"; }

cat > changelog.md <<'EOF'
# Cycle Club app changelog

## Unreleased
- Fix crash when the route list is empty
EOF
who zoe; git add . && d 2025-10-01T09:00:00; git commit -q -m "Changelog"

git switch -q -c release-prep
who yann
cat > changelog.md <<'EOF'
# Cycle Club app changelog

## Unreleased
- Fix crash when the route list is empty
- Add elevation profile to routes
EOF
d 2025-10-03T09:00:00; git commit -q -am "Changelog: elevation profile"

git switch -q main
who zoe
cat > changelog.md <<'EOF'
# Cycle Club app changelog

## Unreleased
- Fix crash when the route list is empty
- Show ride distance in miles or kilometres
EOF
d 2025-10-04T09:00:00; git commit -q -am "Changelog: distance units"
