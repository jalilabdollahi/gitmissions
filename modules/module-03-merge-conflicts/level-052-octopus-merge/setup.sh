#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@devday.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@devday.example"; }

printf '<h1>Hillside Dev Day</h1>\n<p>Saturday 21 June, Hillside Community Hall.</p>\n' > index.html
who kai; git add . && d 2025-05-20T10:00:00; git commit -q -m "Dev day landing page"

git switch -q -c docs
who sana
mkdir docs
printf '# Speaker guide\nSlots are 25 minutes.\n' > docs/speaker-guide.md
git add . && d 2025-05-22T10:00:00; git commit -q -m "Speaker guide"
git switch -q main
git switch -q -c tests
who tariq
mkdir tests
printf '#!/bin/sh\ngrep -q "Dev Day" index.html && echo ok\n' > tests/check-title.sh
chmod +x tests/check-title.sh
git add . && d 2025-05-23T10:00:00; git commit -q -m "Smoke test for the page title"
git switch -q main
git switch -q -c ci
who uma
mkdir ci
printf 'on: push\nsteps:\n  - run: sh tests/check-title.sh\n' > ci/pipeline.yml
git add . && d 2025-05-24T10:00:00; git commit -q -m "CI pipeline"
git switch -q main
git switch -q -c experiment/confetti
who kai
printf '<script>/* confetti */</script>\n' >> index.html
d 2025-05-25T10:00:00; git commit -q -am "Confetti on the landing page (not approved)"
git switch -q main
who kai
printf '<p>Doors open at 9:00.</p>\n' >> index.html
d 2025-05-26T10:00:00; git commit -q -am "Add doors-open time"
