#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf '<h1>Pricing</h1>\n<table><tr><td>Basic</td><td>9</td></tr></table>\n' > pricing.html
printf '<a href="pricing.html">Pricing</a>\n' > index.html
ci Dana "2025-06-02T09:00:00" "Create pricing page"
printf '<tr><td>Pro</td><td>29</td></tr>\n' >> pricing.html
ci Dana "2025-06-03T09:00:00" "Add Pro plan row"
git switch -q -c redesign
printf 'body { font-family: Inter, sans-serif; }\n' > theme.css
sed -i.bak 's#<h1>Pricing</h1>#<h1 class="v2">Pricing</h1>#' pricing.html && rm pricing.html.bak
ci Mei "2025-06-04T10:00:00" "Introduce new theme stylesheet"
printf '.card { border-radius: 12px; }\n' > cards.css
ci Mei "2025-06-05T10:00:00" "Restyle pricing cards"
git switch -q main
printf '<p>Billed annually.</p>\n' >> pricing.html
ci Dana "2025-06-06T09:00:00" "Add annual billing note"
D="2025-06-09T09:00:00"
GIT_AUTHOR_DATE=$D GIT_COMMITTER_DATE=$D git merge -q --no-ff -m "Merge branch 'redesign'" redesign
printf '<h2>FAQ</h2>\n<p>Can I cancel anytime? Yes.</p>\n' > faq.html
ci Tom "2025-06-10T09:00:00" "Add FAQ page"
git rev-parse HEAD > .git/gm-tip
