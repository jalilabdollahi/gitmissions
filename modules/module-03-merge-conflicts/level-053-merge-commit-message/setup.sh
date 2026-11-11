#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@recipeapp.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@recipeapp.example"; }

printf 'body { color: #222; background: #fff; }\n' > theme.css
printf '<footer>Links</footer>\n' > footer.html
who vera; git add . && d 2025-09-02T10:00:00; git commit -q -m "Recipe app base theme"

git switch -q -c feature/dark-mode
who wim
printf 'body { color: #222; background: #fff; }\n:root { --bg-dark: #121212; --fg-dark: #eee; }\n' > theme.css
d 2025-09-04T10:00:00; git commit -q -am "Add dark palette variables"
printf 'body { color: #222; background: #fff; }\n:root { --bg-dark: #121212; --fg-dark: #eee; }\n@media (prefers-color-scheme: dark) { body { background: var(--bg-dark); color: var(--fg-dark); } }\n' > theme.css
d 2025-09-05T10:00:00; git commit -q -am "Follow the system dark mode preference"
printf 'button { color: #fff; }\n' > buttons.css
git add . && d 2025-09-06T10:00:00; git commit -q -m "Fix contrast on buttons"

git switch -q main
who vera
printf '<footer>Links | Privacy</footer>\n' > footer.html
d 2025-09-07T10:00:00; git commit -q -am "Update footer links"
export GIT_COMMITTER_DATE="2025-09-08T10:00:00"
git merge -q --no-ff feature/dark-mode -m "Merge branch 'feature/dark-mode'"
