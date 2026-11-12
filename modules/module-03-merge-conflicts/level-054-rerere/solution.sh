#!/usr/bin/env bash
set -e
git config rerere.enabled true
# First merge: resolve by hand, git rerere records the resolution.
git merge release-prep || true
cat > changelog.md <<'EOF'
# Cycle Club app changelog

## Unreleased
- Fix crash when the route list is empty
- Show ride distance in miles or kilometres
- Add elevation profile to routes
EOF
git add changelog.md
git commit -m "Merge release-prep (first attempt)"
# The release is rebuilt: undo the merge and merge again. rerere reuses the recorded resolution.
git reset --hard HEAD^
git merge release-prep || true
git add changelog.md
git commit -m "Merge release-prep (rebuilt)"
