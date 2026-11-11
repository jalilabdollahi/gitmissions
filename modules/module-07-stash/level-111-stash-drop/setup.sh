#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main wikiwise
cd wikiwise
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'PAGES = []\n' > pages.py
printf 'def old_search(q):\n    return q\n' > legacy_search.py
printf 'EDITOR = "markdown"\n' > editor.py
printf 'FORMATS = ["pdf"]\n' > export.py
git add . && git commit -q -m "Wiki modules"
printf 'PAGES = ["home"]\n' > pages.py && git stash -q
printf 'def old_search(q):\n    return q.lower()\n' > legacy_search.py && git stash -q
git rm -q legacy_search.py
git commit -q -m "Remove legacy search module"
printf 'EDITOR = "wysiwyg"\n' > editor.py && git stash -q
printf 'FORMATS = ["pdf", "docx"]\n' > export.py && git stash -q
