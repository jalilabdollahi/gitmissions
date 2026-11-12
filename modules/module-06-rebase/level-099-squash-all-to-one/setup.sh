#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main giftlist
cd giftlist
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'GIFTS = []\n' > gifts.py && c "Create gift model"
git switch -q -c feature/registry-sharing
printf 'STEP = 1\n' > registry.py && c "Start registry sharing"
printf 'def link(r):\n    return "/r/" + r\n' > share.py && c "Add share link"
printf 'STEP = 3\n' > registry.py && c "wip"
printf 'def mail(r):\n    return "sent"\n' > notify.py && c "Notify invitees by mail"
printf 'STEP = 5\n' > registry.py && c "more wip"
printf 'from registry import STEP\nassert STEP\n' > test_registry.py && c "Add registry tests"
printf 'STEP = 7\n' > registry.py && c "Final tweaks"
