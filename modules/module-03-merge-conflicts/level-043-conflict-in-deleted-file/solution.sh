#!/usr/bin/env bash
set -e
git merge update-phones || true      # CONFLICT (modify/delete)
# The file was deleted on purpose; carry the new number over into contacts.csv.
git rm -q legacy-contacts.txt
sed -i.bak 's/^first-aid,Dr Novak,555-0111/first-aid,Dr Novak,555-0199/' contacts.csv && rm contacts.csv.bak
git add contacts.csv
git commit -m "Merge update-phones: Dr Novak's new number lives in contacts.csv"
