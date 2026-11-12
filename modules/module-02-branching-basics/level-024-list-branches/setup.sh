#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# A bare "server" repository next to the working clone
git init -q --bare -b main origin.git
git clone -q origin.git seed
(
  cd seed
  git config user.name "Ilse"; git config user.email "ilse@lenscollective.example"; git config commit.gpgsign false
  export GIT_AUTHOR_DATE="2025-05-05T10:00:00" GIT_COMMITTER_DATE="2025-05-05T10:00:00"
  printf 'Lens Collective gallery\n' > gallery.md
  git add . && git commit -q -m "Gallery page"
  git push -q origin HEAD:main
  for b in develop feature/slideshow feature/captions hotfix/broken-links release/2025-05; do
    git switch -q -c "$b" main
    mkdir -p work
    printf '%s\n' "$b" > "work/$(echo "$b" | tr '/' '-').txt"
    git add . && GIT_AUTHOR_DATE="2025-05-06T10:00:00" GIT_COMMITTER_DATE="2025-05-06T10:00:00" git commit -q -m "Work on $b"
    git push -q origin "$b"
  done
)
rm -rf seed

git clone -q origin.git photos
cd photos
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git switch -q -c feature/slideshow origin/feature/slideshow
git switch -q main
