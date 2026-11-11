#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main panfry
cd panfry
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'class Recipe:\n    pass\n' > recipe.py && c "Add recipe model"
printf 'def parse(line):\n    return line.split(",")\n' > ingredients.py && c "Add ingredient parser"
printf 'def safe(recipe, allergens):\n    return not allergens\n' > allergens.py && c "Add allergen filter"
git switch -q -c feature/meal-planner
printf 'PLAN = {}\n' > planner.py && c "Prototype weekly planner"
git switch -q main
printf 'def export(items):\n    return "\\n".join(items)\n' > shopping.py && c "Add shopping list export"
git switch -q --detach "$(git log --format=%H -1 --grep='Add allergen filter' main)"
