#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main hosting.git
mkdir newsletter
cd newsletter
git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

mkdir templates
printf 'subject = "Welcome to Brightletter"\n' > templates/welcome.html
git add . && git commit -q -m "Add welcome template"
printf 'import csv\n\ndef load(path):\n    return list(csv.DictReader(open(path)))\n' > send.py
git add . && git commit -q -m "Add subscriber loader"
printf 'email,status\nana@example.com,active\nomar@example.com,unsubscribed\n' > subscribers.csv
git add . && git commit -q -m "Seed sample subscribers"
printf '\ndef active(rows):\n    return [r for r in rows if r["status"] == "active"]\n' >> send.py
git add . && git commit -q -m "Skip unsubscribed readers"

git switch -q -c draft-templates
printf 'subject = "Spring digest (draft)"\n' > templates/spring.html
git add . && git commit -q -m "Draft spring digest template"
git switch -q main
