#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main docsmith
cd docsmith
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'dist/\n' > .gitignore
cat > build.sh <<'SH'
mkdir -p dist
printf 'docs built for version %s from commit %s\n' "$(cat VERSION)" "$(git rev-parse --short HEAD)" > dist/site.txt
SH
printf '1.7.0\n' > VERSION && c "Docs generator skeleton"
printf '1.8.0-rc1\n' > VERSION && c "Prepare 1.8.0 release candidate"
git tag v1.8.0-rc1
printf '1.8.0\n' > VERSION && c "Release 1.8.0"
git tag v1.8.0
printf 'sidebar: left\n' > theme.yml && c "Fix sidebar overlap"
printf '1.8.1\n' > VERSION && c "Release 1.8.1"
git tag v1.8.1
printf '1.9.0-dev\n' > VERSION && c "Start 1.9 development"
