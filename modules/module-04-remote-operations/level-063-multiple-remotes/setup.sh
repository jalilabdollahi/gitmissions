#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main upstream.git
git clone -q upstream.git seed 2>/dev/null
cd seed
git config user.name "Maintainer"
git config user.email "maint@pulse.dev"
git config commit.gpgsign false
printf 'export function track(event) { return event; }\n' > track.js
git add . && git commit -q -m "Add track()"
printf 'export const VERSION = "0.4.0";\n' > version.js
git add . && git commit -q -m "Bump to 0.4.0"
git push -q origin main

cd "$SANDBOX"
git clone -q --bare upstream.git origin.git
git clone -q origin.git pulse-sdk 2>/dev/null
cd pulse-sdk
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

cd "$SANDBOX/seed"
printf 'export function identify(id) { return id; }\n' > identify.js
git add . && git commit -q -m "Add identify()"
printf 'export const VERSION = "0.5.0";\n' > version.js
git commit -q -am "Bump to 0.5.0"
git push -q origin main
