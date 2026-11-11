#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Giulia" GIT_AUTHOR_EMAIL="giulia@sweetcrumb.example"
export GIT_COMMITTER_NAME="Giulia" GIT_COMMITTER_EMAIL="giulia@sweetcrumb.example"
export GIT_AUTHOR_DATE="2025-02-14T07:00:00" GIT_COMMITTER_DATE="2025-02-14T07:00:00"

cat > menu.html <<'EOF'
<ul class="menu">
  <li>Sourdough loaf - 6.50</li>
  <li>Almond croissant - 3.20</li>
  <li>Cardamom bun - 2.90</li>
  <li>Rye baguette - 4.10</li>
</ul>
EOF
cat > style.css <<'EOF'
.menu { list-style: none; font-size: 1.1rem; }
.menu li { padding: 0.3rem 0; }
EOF
git add .
git commit -q -m "Sweet Crumb menu page"

# A botched search-and-replace that wrecked the prices
sed -i.bak 's/ - [0-9.]*</ - 0.00</' menu.html && rm menu.html.bak
# A good style tweak that is not ready to commit yet
printf '.menu li:hover { background: #ffe9c7; }\n' >> style.css
