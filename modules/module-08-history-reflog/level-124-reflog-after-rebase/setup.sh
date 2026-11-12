#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'VERSION=1.3.0\n' > VERSION
printf 'boot: stage1\n' > bootloader.cfg
ci Dana "2025-10-01T09:00:00" "Initial boot loader config"
printf 'watchdog: 8s\n' >> bootloader.cfg
ci Dana "2025-10-02T09:00:00" "Enable hardware watchdog"
git switch -q -c feature/ota-update
printf 'int ota_download(const char *url);\n' > ota.c
ci Ravi "2025-10-03T10:00:00" "Add OTA download client"
printf 'slot_a,0x10000\nslot_b,0x90000\nrollback,0x110000\n' > partitions.csv
ci Ravi "2025-10-04T10:00:00" "Add rollback partition table"
printf 'int verify_image(const void *img);\n' > verify.c
ci Ravi "2025-10-05T10:00:00" "Verify image signature before flashing"
printf 'void led_progress(int pct);\n' > led.c
ci Ravi "2025-10-06T10:00:00" "Add OTA progress LED"
git switch -q main
printf 'VERSION=1.4.0\n' > VERSION
ci Dana "2025-10-07T09:00:00" "Bump firmware to 1.4.0"
git switch -q feature/ota-update
git rev-parse HEAD > .git/gm-orig-tip
GIT_COMMITTER_DATE="2025-10-08T09:00:00" GIT_SEQUENCE_EDITOR="sed -i.bak -e '2s/^pick/drop/'" git rebase -q -i main
