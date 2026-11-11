#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@foodtruck.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@foodtruck.example"; }

cat > menu.txt <<'EOF'
TACO TRUCK MENU
Beef taco 4.50
Veggie taco 4.00
Churros 3.50
Lemonade 2.00
Horchata 2.50
EOF
who carlos; git add . && d 2025-06-01T11:00:00; git commit -q -m "Taco truck menu"

git switch -q -c dinner-service
who dana
git mv menu.txt menu-dinner.txt
printf 'Fish taco 5.50\n' >> menu-dinner.txt
git add . && d 2025-06-08T11:00:00; git commit -q -m "Rename menu for dinner service and add fish taco"

git switch -q main
who carlos
git mv menu.txt menu-lunch.txt
sed -i.bak 's/^Beef taco 4.50/Beef taco 4.75/' menu-lunch.txt && rm menu-lunch.txt.bak
git add . && d 2025-06-09T11:00:00; git commit -q -m "Rename menu for lunch service, raise beef taco price"
