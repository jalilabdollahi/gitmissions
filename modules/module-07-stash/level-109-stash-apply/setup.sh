#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main metaboost
cd metaboost
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf '<head>\n<title>Shop</title>\n</head>\n' > layout.html
git add . && git commit -q -m "Create base layout"
git branch release/blue
git branch release/green
printf '<head>\n<title>Shop</title>\n<meta name="description" content="Fast shop">\n</head>\n' > layout.html
git stash push -q -m "SEO meta tags"
