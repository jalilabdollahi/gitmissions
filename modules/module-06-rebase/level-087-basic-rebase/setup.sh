#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main markbook
cd markbook
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'bookmarks = []\n' > store.js && c "Create bookmark store"
git switch -q -c feature/folders
printf 'class Folder {}\n' > folder.js && c "Add folder model"
printf '<aside id="folders"></aside>\n' > sidebar.html && c "Add folder sidebar"
git switch -q main
printf 'import chrome\n' > import.js && c "Add import from Chrome"
printf 'dedupe = true\n' > dedupe.js && c "Add duplicate detection"
git switch -q feature/folders
