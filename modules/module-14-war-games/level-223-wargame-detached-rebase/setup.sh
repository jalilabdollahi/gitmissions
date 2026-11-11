#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main origin.git
git clone -q origin.git work 2>/dev/null
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir theme
printf 'title: My Site\n' > config.yaml
printf '# site\n' > README.md
git add -A; ci Lotte lotte@site.dev "2025-08-01T09:00:00" "Site skeleton"
git push -q origin main 2>/dev/null
git switch -q -c feature/a
printf '.btn { color: #333; }\n' > theme/base.css
git add -A; ci Lotte lotte@site.dev "2025-08-04T09:00:00" "theme: add base styles"
printf '.mt-1 { margin-top: 4px; }\n' >> theme/base.css
git add -A; ci Lotte lotte@site.dev "2025-08-05T09:00:00" "theme: add spacing scale"
git switch -q -c feature/b
printf ':root { --bg: #111; --fg: #eee; }\n' > theme/dark.css
git add -A; ci Player player@gitmissions.local "2025-08-06T09:00:00" "theme: dark mode variables"
printf '.btn { color: var(--fg, #333); }\n.mt-1 { margin-top: 4px; }\n' > theme/base.css
printf '// toggle dark mode\n' > theme/toggle.js
git add -A; ci Player player@gitmissions.local "2025-08-07T09:00:00" "theme: dark mode toggle"
git push -q origin feature/a feature/b 2>/dev/null
git switch -q main
git merge -q --squash feature/a >/dev/null
ci Lotte lotte@site.dev "2025-08-10T09:00:00" "Add base theme (#12)"
printf '\nTheme docs: see theme/base.css\n' >> README.md
git add -A; ci Lotte lotte@site.dev "2025-08-11T09:00:00" "docs: theme readme"
git push -q origin main 2>/dev/null
git switch -q feature/b
git rebase main >/dev/null 2>&1 || true
