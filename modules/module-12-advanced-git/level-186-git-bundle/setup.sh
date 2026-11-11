#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

mkdir obc-firmware && cd obc-firmware
git init -q -b main
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir src
printf 'void boot(void) { /* init watchdog */ }\n' > src/boot.c
printf 'void adcs_loop(void) {}\n' > src/adcs.c
git add -A; ci Lucia lucia@orbit.io "2025-01-06T09:00:00" "boot and attitude control skeleton"
printf 'void telemetry_tx(void) {}\n' > src/tm.c
git add -A; ci Lucia lucia@orbit.io "2025-01-20T09:00:00" "telemetry transmitter"
git tag v1.0
printf 'void safe_mode(void) {}\n' > src/safe.c
git add -A; ci Karim karim@orbit.io "2025-02-11T09:00:00" "safe mode on brown-out"
printf 'void adcs_loop(void) { /* sun sensor fusion */ }\n' > src/adcs.c
git add -A; ci Karim karim@orbit.io "2025-02-25T09:00:00" "sun sensor fusion"
git tag v2.0
printf 'void ota_update(void) {}\n' > src/ota.c
git add -A; ci Lucia lucia@orbit.io "2025-03-10T09:00:00" "over-the-air update stub"
printf 'void thermal(void) {}\n' > src/thermal.c
git add -A; ci Karim karim@orbit.io "2025-03-18T09:00:00" "thermal control loop"
git switch -q -c develop
printf 'void payload_camera(void) {}\n' > src/camera.c
git add -A; ci Lucia lucia@orbit.io "2025-03-22T09:00:00" "payload camera driver (experimental)"
git switch -q main
