#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main duskline
cd duskline
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf ':root { --bg: #fff; }\n' > base.css && c "Add base styles"
git switch -q -c feature/dark-mode
mkdir theme docs
printf '[data-theme=dark] { --bg: #111; }\n' > theme/tokens.css && c "wip"
printf 'export const toggle = () => document.documentElement.dataset.theme = "dark";\n' > theme/toggle.js && c "stuff"
printf '# Dark mode\nSet data-theme=dark.\n' > docs/dark-mode.md && c "more"
