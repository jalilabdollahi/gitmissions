#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main calendrix
cd calendrix
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'EVENTS = []\n' > events.py && c "Create event store"
git switch -q -c feature/ical
printf 'def sync():\n    return "synced"\n' > sync.py && c "Add calendar sync job"
printf 'from tz import LOCAL\n\ndef to_ical(events):\n    return "BEGIN:VCALENDAR"\n' > ical.py && c "Add iCal export"
printf 'LOCAL = "Europe/Berlin"\n' > tz.py && c "oops forgot timezone file"
