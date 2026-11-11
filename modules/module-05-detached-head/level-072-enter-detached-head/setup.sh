#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main coinjar
cd coinjar
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf '{\n  "round_up": false\n}\n' > flags.json && c "Create flags file"
printf '{\n  "round_up": false,\n  "dark_mode": false\n}\n' > flags.json && c "Add dark_mode flag"
printf '{\n  "round_up": false,\n  "dark_mode": true\n}\n' > flags.json && c "Enable dark mode"
printf '{\n  "round_up": false,\n  "dark_mode": true,\n  "streaks": false\n}\n' > flags.json && c "Add spending streaks flag"
printf '{\n  "round_up": true,\n  "dark_mode": true,\n  "streaks": false\n}\n' > flags.json && c "Launch savings jar"
printf '{\n  "round_up": true,\n  "dark_mode": true,\n  "streaks": true\n}\n' > flags.json && c "Enable streaks for everyone"
printf 'Keep your streak alive!\n' > copy.txt && c "Tune streak copy"
