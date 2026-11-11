#!/usr/bin/env bash
set -e
git merge weekend-sessions || true
# Both sides only appended rows: keep every row, so just drop the marker lines.
for f in members.csv kiln-bookings.csv supplies.csv; do
  sed -i.bak -e '/^<<<<<<< /d' -e '/^=======$/d' -e '/^>>>>>>> /d' "$f"
  rm "$f.bak"
  git add "$f"
done
git commit -m "Merge weekend-sessions: keep all new members, bookings and supplies"
