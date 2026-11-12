#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@oakstreet.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@oakstreet.example"; }

cat > legacy-contacts.txt <<'EOF'
Oak Street neighbourhood association - contacts
Chair: Wanda 555-0100
Treasurer: Hugh 555-0101
Dr Novak (street first-aid volunteer): 555-0111
EOF
cat > contacts.csv <<'EOF'
role,name,phone
chair,Wanda,555-0100
treasurer,Hugh,555-0101
EOF
who wanda; git add . && d 2025-01-08T19:00:00; git commit -q -m "Contacts list and a spreadsheet version"

git switch -q -c update-phones
who hugh
sed -i.bak 's/555-0111/555-0199/' legacy-contacts.txt && rm legacy-contacts.txt.bak
d 2025-01-15T19:00:00; git commit -q -am "Dr Novak changed her number"

git switch -q main
who wanda
printf 'first-aid,Dr Novak,555-0111\n' >> contacts.csv
git rm -q legacy-contacts.txt
d 2025-01-16T19:00:00; git commit -q -m "Move everything into contacts.csv, delete the old text file"
