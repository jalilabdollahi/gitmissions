#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Jun" GIT_AUTHOR_EMAIL="jun@albumart.example" GIT_COMMITTER_NAME="Jun" GIT_COMMITTER_EMAIL="jun@albumart.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

printf 'body { background: #fafafa; color: #222; }\n' > theme.css
printf '<h1>Moonlight Quartet - album art portfolio</h1>\n' > index.html
git add . && d 2025-08-10T11:00:00; git commit -q -m "Portfolio base theme"

git switch -q -c experiment/neon-theme
printf 'body { background: #0a0020; color: #39ff14; }\n' > theme.css
d 2025-08-11T11:00:00; git commit -q -am "Neon green on black"
printf 'body { background: #0a0020; color: #39ff14; text-shadow: 0 0 6px #39ff14; }\n' > theme.css
d 2025-08-12T11:00:00; git commit -q -am "Add glow effect"
git config gitmissions.neonTip "$(git rev-parse HEAD)"
git switch -q main
printf 'body { background: #fafafa; color: #222; }\nh1 { font-weight: 300; }\n' > theme.css
git add . && d 2025-08-13T11:00:00; git commit -q -m "Lighter headings"
git branch feature/contact-form
