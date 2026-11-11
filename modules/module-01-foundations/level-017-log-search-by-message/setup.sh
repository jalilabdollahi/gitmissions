#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

c() { # date message
  printf '%s\n' "$2" >> rota.py
  GIT_AUTHOR_NAME="Dmitri" GIT_AUTHOR_EMAIL="dmitri@volunteerfire.example" GIT_AUTHOR_DATE="$1" \
  GIT_COMMITTER_NAME="Dmitri" GIT_COMMITTER_EMAIL="dmitri@volunteerfire.example" GIT_COMMITTER_DATE="$1" \
  git commit -q -am "$3"
}
printf '# shift rota for the volunteer fire brigade\n' > rota.py
git add rota.py
GIT_AUTHOR_DATE=2025-01-10T09:00:00 GIT_COMMITTER_DATE=2025-01-10T09:00:00 git commit -q -m "Start rota script"
c 2025-01-17T09:00:00 "MAX_HOURS = 48" "Weekly hours cap"
c 2025-01-24T09:00:00 "NIGHT_BONUS = 1.5" "Overtime rules for night shifts"
c 2025-02-03T09:00:00 "def extra_hours(h): return max(0, h - 40)" "Extra hours calculation"
c 2025-02-10T09:00:00 "ROUND_TO = 0.25" "Round to quarter hours"
c 2025-02-18T09:00:00 "# rounding fix" "Fix OVERTIME rounding for part-timers"
c 2025-02-25T09:00:00 "HOLIDAY = 2.0" "Holiday multiplier"
c 2025-03-04T09:00:00 "CAP_OT = 12" "Cap on overtime per month (see issue 31)"
c 2025-03-11T09:00:00 "# tidy" "Tidy imports"
