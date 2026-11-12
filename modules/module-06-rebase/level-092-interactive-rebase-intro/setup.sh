#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main ticketboard
cd ticketboard
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'columns = ["todo", "doing", "done"]\n' > board.py && c "initial"
printf 'class Ticket:\n    title = ""\n' > ticket.py && c "Add ticket model"
printf 'assignee = None\n' > assignee.py && c "Add assignee field"
printf 'due = None\n' > due.py && c "Add due dates"
