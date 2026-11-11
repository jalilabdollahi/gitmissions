#!/usr/bin/env bash
set -e
git merge dinner-service || true       # CONFLICT (rename/rename)
# Keep the dinner name; Git already merged both content edits into it.
git rm -q menu-lunch.txt
git add menu-dinner.txt
git rm -q --ignore-unmatch menu.txt
git commit -m "Merge dinner-service: single menu-dinner.txt"
