#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

mkdir registry workspace
git init -q --bare -b main registry/design-kit.git
git clone -q registry/design-kit.git seed 2>/dev/null
cd seed
git config user.name "Rhea"
git config user.email "rhea@kitchensink.dev"
git config commit.gpgsign false
mkdir tokens
printf '{ "primary": "#2255cc", "radius": 4 }\n' > tokens/colors.json
git add . && git commit -q -m "Define 2.x design tokens"
printf 'export const Button = () => null;\n' > button.js
git add . && git commit -q -m "Add Button component"
git push -q origin main
git switch -q -c release/2.x
printf 'export const Button = () => "2.x";\n' > button.js
git add . && git commit -q -m "Mark 2.x button for maintenance"
git push -q origin release/2.x
git switch -q main
printf '{ "primary": "#1a47e0", "radius": 8 }\n' > tokens/colors.json
git add . && git commit -q -m "Rebrand tokens for 3.0"
git push -q origin main
cd ..
rm -rf seed
