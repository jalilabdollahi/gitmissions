#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main wordly
cd wordly
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
for l in en de fr; do
  printf '{\n  "title": "Wordly",\n  "checkout": "Checkout"\n}\n' > "$l.json"
done
c "Add language files"
git switch -q -c feature/i18n-hints
printf '{\n  "title": "Wordly",\n  "checkout": "Proceed to checkout",\n  "checkout_hint": "Review your cart first"\n}\n' > en.json && c "Add English checkout hint"
printf '{\n  "title": "Wordly",\n  "checkout": "Weiter zur Kasse",\n  "checkout_hint": "Bitte Warenkorb pruefen"\n}\n' > de.json && c "Add German checkout hint"
printf '{\n  "title": "Wordly",\n  "checkout": "Passer a la caisse",\n  "checkout_hint": "Verifiez votre panier"\n}\n' > fr.json && c "Add French checkout hint"
git switch -q main
printf '{\n  "title": "Wordly",\n  "checkout": "Pay now"\n}\n' > en.json
printf '{\n  "title": "Wordly",\n  "checkout": "Jetzt bezahlen"\n}\n' > de.json
printf '{\n  "title": "Wordly",\n  "checkout": "Payer maintenant"\n}\n' > fr.json
c "Shorten checkout call to action"
git switch -q feature/i18n-hints
