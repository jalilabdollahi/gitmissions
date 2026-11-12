#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main tunelist
cd tunelist
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'class Playlist: pass\n' > playlist.py && c "Create playlist model"
printf 'def shuffle(p): return p\n' > shuffle.py && c "Add shuffle mode"
git switch -q -c feature/crossfade
printf 'FADE = 3\n' > fade.py && c "Fade tracks over 3 seconds"
printf 'FADE = None  # user setting\n' > fade.py && c "Make crossfade length configurable"
git switch -q main
printf 'def share(p): return "link"\n' > share.py && c "Add playlist sharing"
git merge -q --no-ff feature/crossfade -m "Merge crossfade into main"
git branch -q -D feature/crossfade
