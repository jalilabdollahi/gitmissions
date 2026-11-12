#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main snapgrid
cd snapgrid
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf '<div class="grid"></div>\n' > grid.html && c "Create gallery grid"
git switch -q -c feature/captions
printf 'photo.caption = ""\n' > caption.js && c "Add caption field"
printf 'render(photo.caption)\n' > render_captions.js && c "Render captions under photos"
git switch -q main
printf 'cache = {}\n' > thumbs.js && c "Add thumbnail cache"
printf 'loading = "lazy"\n' > lazy.js && c "Lazy-load images"
git switch -q feature/captions
