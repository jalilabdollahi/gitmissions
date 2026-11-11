#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Lena" GIT_AUTHOR_EMAIL="lena@lenapark.example" GIT_COMMITTER_NAME="Lena" GIT_COMMITTER_EMAIL="lena@lenapark.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

printf '<h1>Lena Park</h1>\n<nav>Home | Contact</nav>\n' > index.html
printf 'Write to lena@lenapark.example\n' > contact.html
git add . && d 2025-10-01T10:00:00; git commit -q -m "Home and contact pages"
printf 'Write to lena@lenapark.example\nOr call 555-0188\n' > contact.html
d 2025-10-03T10:00:00; git commit -q -am "Update contact page"

git switch -q -c photo-gallery
mkdir gallery
printf '<img src="forest.jpg" alt="Forest at dawn">\n' > gallery/index.html
git add . && d 2025-10-05T10:00:00; git commit -q -m "Gallery page with first photo"
printf '<img src="forest.jpg" alt="Forest at dawn">\n<img src="harbor.jpg" alt="Harbor at night">\n' > gallery/index.html
d 2025-10-06T10:00:00; git commit -q -am "Add harbor photo"
git switch -q main
