#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main findly
cd findly
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf 'awk -F= '"'"'{s+=$2} END{exit (s==100)?0:1}'"'"' weights.conf\n' > check.sh
i=0
for w in alpha bravo cedar delta ember fjord gamma harbor indigo juniper kestrel lumen meadow nimbus onyx prism quartz raven sable tundra umber vertex; do
  i=$((i + 1))
  k=$((i % 3))
  pop=10
  if [ "$i" -ge 14 ]; then pop=15; fi
  printf 'title=%s\nbody=30\nrecency=%s\npopularity=%s\n' "$((40 + k))" "$((20 - k))" "$pop" > weights.conf
  printf 'pass %s: %s\n' "$i" "$w" >> changelog.txt
  git add -A
  git commit -q -m "Tune $w ranking"
done
