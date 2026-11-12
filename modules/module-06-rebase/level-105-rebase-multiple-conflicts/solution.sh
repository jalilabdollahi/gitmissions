#!/usr/bin/env bash
set -e
git rebase main || true
fix() {  # file, checkout label, hint
  printf '{\n  "title": "Wordly",\n  "checkout": "%s",\n  "checkout_hint": "%s"\n}\n' "$2" "$3" > "$1"
  git add "$1"
  git -c core.editor=true rebase --continue || true
}
fix en.json "Pay now" "Review your cart first"
fix de.json "Jetzt bezahlen" "Bitte Warenkorb pruefen"
fix fr.json "Payer maintenant" "Verifiez votre panier"
