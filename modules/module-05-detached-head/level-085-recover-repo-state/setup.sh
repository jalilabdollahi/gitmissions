#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main parcelo
cd parcelo
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'ETA_BUFFER_MIN = 10\nROUND_TO = 5\n' > eta.py && c "Add ETA calculator"
printf 'def track(parcel):\n    return parcel\n' > tracking.py && c "Add tracking endpoint"
git tag v2.4.0
printf 'ETA_BUFFER_MIN = 15\nROUND_TO = 5\n' > eta.py && c "Raise ETA buffer to 15 minutes"
printf 'def notify(parcel):\n    return "sent"\n' > notifications.py && c "Add delivery notifications"
git switch -q --detach v2.4.0
printf 'ETA_BUFFER_MIN = 10\nROUND_TO = 1\n' > eta.py && c "Round ETA to the minute"
printf 'from eta import ROUND_TO\nassert ROUND_TO == 1\n' > test_eta.py && c "Test ETA rounding"
git switch -q main
