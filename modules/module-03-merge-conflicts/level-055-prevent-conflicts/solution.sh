#!/usr/bin/env bash
set -e
# 1. Integrate main INTO the feature branch and resolve the conflict there.
git switch feature/summer-programme
git merge main || true
cat > programme.md <<'EOF'
# Season programme
Autumn: Brahms Symphony 2
Winter: carols evening with brass guests (sold out, add a second night)
Spring: Dvorak Symphony 9
Summer: Gala in the park
EOF
git add programme.md
git commit -m "Merge main into feature/summer-programme"
# 2. main can now simply fast-forward: no conflicts will ever reach it.
git switch main
git merge --ff-only feature/summer-programme
