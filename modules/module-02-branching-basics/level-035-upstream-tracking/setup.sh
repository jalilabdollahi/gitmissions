#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q --bare -b main origin.git
mkdir local && cd local
git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Maren" GIT_AUTHOR_EMAIL="maren@pta.example" GIT_COMMITTER_NAME="Maren" GIT_COMMITTER_EMAIL="maren@pta.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

printf '<h1>Spring Fundraiser</h1>\n<p>Saturday 12 April, school hall.</p>\n' > index.html
git add . && d 2025-03-20T16:00:00; git commit -q -m "Fundraiser landing page"
git remote add origin ../origin.git
git push -q origin main        # pushed without -u: no tracking configured

git switch -q -c feature/rsvp
printf '<form action="/rsvp"><input name="family"></form>\n' > rsvp.html
git add . && d 2025-03-22T16:00:00; git commit -q -m "RSVP form"
