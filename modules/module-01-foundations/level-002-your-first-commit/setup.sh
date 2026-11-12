#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

mkdir recipes
cat > recipes/pancakes.md <<'EOF'
# Sunday Pancakes
- 200 g flour
- 2 eggs
- 300 ml milk
- pinch of salt

Whisk, rest 10 minutes, fry in butter.
EOF
cat > recipes/lentil-soup.md <<'EOF'
# Red Lentil Soup
- 250 g red lentils
- 1 onion, 2 carrots
- 1 l vegetable stock
- cumin

Simmer 25 minutes, blend half of it.
EOF
cat > recipes/granola.md <<'EOF'
# Maple Granola
- 300 g oats
- 80 ml maple syrup
- handful of almonds

Bake at 150 C for 25 minutes, stirring once.
EOF
printf 'olive oil\nred lentils\nmaple syrup\n' > shopping-list.txt
