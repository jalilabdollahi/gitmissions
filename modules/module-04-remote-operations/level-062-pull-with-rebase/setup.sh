#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git menu-service 2>/dev/null
cd menu-service
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config pull.rebase false
printf '[{"id": 1, "name": "Margherita", "price": 9.5}]\n' > menu.json
git add . && git commit -q -m "Seed menu"
git push -q origin main

cd "$SANDBOX"
git clone -q origin.git mate 2>/dev/null
cd mate
git config user.name "Mira"
git config user.email "mira@forkful.dev"
git config commit.gpgsign false
printf 'VEGAN = ["Margherita"]\n' > vegan.py
git add . && git commit -q -m "Add vegan flag to menu items"
git push -q origin main

cd "$SANDBOX/menu-service"
printf 'ALLERGENS = {"Margherita": ["gluten", "milk"]}\n' > allergens.py
git add . && git commit -q -m "Add allergen list"
printf 'CALORIES = {"Margherita": 780}\n' > calories.py
git add . && git commit -q -m "Show calories"
