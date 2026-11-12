#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
git clone -q origin.git checkout 2>/dev/null
cd checkout
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'export const total = (items) => items.reduce((s, i) => s + i.price, 0);\n' > cart.js
printf 'export const coupon = (t, c) => t * (1 - c);\n' > coupon.js
git add . && git commit -q -m "Compute cart total"
git push -q origin main

printf 'export const shipping = (kg) => 4.5 + kg * 1.2;\n' > shipping.js
git add . && git commit -q -m "Add shipping estimator"
printf 'export const validPostal = (s) => /^[0-9]{5}$/.test(s);\n' > postal.js
git add . && git commit -q -m "Validate postal codes"

git switch -q -c experiment-apple-pay
printf 'export const applePay = () => "todo";\n' > applepay.js
git add . && git commit -q -m "Prototype Apple Pay sheet"
git switch -q main

printf 'export const coupon = (t, c) => t * (1 - c) + tax(t);\n' > coupon.js
