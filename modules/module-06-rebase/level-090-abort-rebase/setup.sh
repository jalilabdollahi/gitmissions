#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main pollcraft
cd pollcraft
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'def summarize(rows):\n    return len(rows)\n' > results.py && c "Summarize survey results"
git switch -q -c feature/export-csv
printf 'import csv\n' > export.py && c "Add CSV exporter"
printf 'def summarize(rows):\n    return {"count": len(rows)}\n' > results.py && c "Return summary as a dict"
printf '<button id="export">Export</button>\n' > button.html && c "Add export button"
git switch -q main
printf 'def summarize(rows):\n    return len(set(rows))\n' > results.py && c "Count unique respondents only"
git switch -q feature/export-csv
git rebase main >/dev/null 2>&1 || true
