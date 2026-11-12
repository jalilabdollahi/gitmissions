#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main deskly
cd deskly
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'TICKETS = []\n' > base.py && c "Create ticket store"
git switch -q -c feature/ticket-export
printf 'def list_view(t):\n    return t\n' > tickets.py && c "Add ticket list view"
printf 'HELPDESK_API_KEY=sk_live_51Hx9y2eZvKYlo2C0\n' > .env.production && c "Add temporary debug credentials"
printf 'def by_status(t, s):\n    return [x for x in t if x == s]\n' > filters.py && c "Add status filter"
