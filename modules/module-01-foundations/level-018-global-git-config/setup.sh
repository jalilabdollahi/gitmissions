#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

mkdir -p contacts
printf 'Vet: Dr Hale 555-0142\nPlumber: Ostrowski 555-0177\nSchool office: 555-0103\n' > contacts/emergency.txt
git add .
git commit -q -m "Create emergency contacts sheet" --date="2025-10-01T09:00:00"

printf 'Vet: Dr Hale 555-0199\nPlumber: Ostrowski 555-0177\nSchool office: 555-0103\n' > contacts/emergency.txt
git add contacts/emergency.txt
