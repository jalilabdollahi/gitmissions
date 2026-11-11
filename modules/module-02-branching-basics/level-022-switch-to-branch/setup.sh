#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Alba" GIT_AUTHOR_EMAIL="alba@cityguide.example" GIT_COMMITTER_NAME="Alba" GIT_COMMITTER_EMAIL="alba@cityguide.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

mkdir en
printf 'Museum of Clocks\nOpen Tue-Sun 10:00-17:00\n' > en/hours.txt
printf 'Welcome to the Museum of Clocks.\n' > en/welcome.txt
git add . && d 2025-06-02T10:00:00; git commit -q -m "English visitor guide"

git branch translation-fr
git branch translation-es
git switch -q translation-fr
mkdir fr
printf 'Bienvenue au Musee des Horloges.\n' > fr/accueil.txt
git add . && d 2025-06-04T10:00:00; git commit -q -m "French welcome text"
git switch -q translation-es
mkdir es
printf 'Bienvenidos al Museo de los Relojes.\n' > es/bienvenida.txt
git add . && d 2025-06-05T10:00:00; git commit -q -m "Spanish welcome text"
git switch -q main
