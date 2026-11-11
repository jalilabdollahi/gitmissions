#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

mkdir -p alerts docs
printf '[station]\nid = "alpine-07"\ninterval_s = 60\n' > sensors.toml
printf '[limit]\ntemp_c = 40\n' > alerts/threshold.toml
printf '# Notes\nRotate batteries yearly.\n' > docs/notes.md
git add -A; ci Greta greta@sensors.net "2025-01-13T08:00:00" "Initial station config"
printf '[limit]\ntemp_c = 40\nwind_ms = 25\n' > alerts/threshold.toml
git add -A; ci Greta greta@sensors.net "2025-01-20T08:00:00" "Add wind limit"
printf '[station]\nid = "alpine-07"\ninterval_s = 30\n' > sensors.toml
git add -A; ci Hiro hiro@sensors.net "2025-02-03T08:00:00" "Sample every 30 seconds"
git tag -a v1.0 -m "sensor config 1.0"
printf '# Notes\nRotate batteries yearly.\nClear the snow from the mast.\n' > docs/notes.md
git add -A; ci Hiro hiro@sensors.net "2025-02-17T08:00:00" "Winter maintenance note"
printf '[station]\nid = "alpine-07"\ninterval_s = 30\nlora = true\n' > sensors.toml
git add -A; ci Greta greta@sensors.net "2025-03-03T08:00:00" "Enable LoRa uplink"
printf '[limit]\ntemp_c = 35\nwind_ms = 25\n' > alerts/threshold.toml
git add -A; ci Hiro hiro@sensors.net "2025-03-10T08:00:00" "Lower the temperature limit"
