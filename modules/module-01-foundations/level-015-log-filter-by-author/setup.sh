#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# c <author name> <author email> <committer name> <date> <line> <message>
c() {
  printf '%s\n' "$5" >> catalog.csv
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$4" \
  GIT_COMMITTER_NAME="$3" GIT_COMMITTER_EMAIL="x@library.example" GIT_COMMITTER_DATE="$4" \
  git commit -q -am "$6"
}
printf 'title,author,shelf\n' > catalog.csv
git add catalog.csv
GIT_AUTHOR_DATE=2025-04-01T10:00:00 GIT_COMMITTER_DATE=2025-04-01T10:00:00 git commit -q -m "Create catalog"
c "Marta Kowalski" marta.k@library.example "Marta Kowalski" 2025-04-02T10:00:00 "Dune,Herbert,SF-1" "Add Dune"
c "Marta Lindqvist" marta.l@library.example "Marta Lindqvist" 2025-04-03T10:00:00 "Emma,Austen,C-4" "Add Emma"
c "Marcus Bell" marcus@library.example "Marcus Bell" 2025-04-04T10:00:00 "Beloved,Morrison,C-9" "Add Beloved"
c "Marta Kowalski" marta.k@library.example "Marta Kowalski" 2025-04-05T10:00:00 "Kindred,Butler,SF-2" "Add Kindred"
c "Leo Park" leo@library.example "Marta Kowalski" 2025-04-06T10:00:00 "Hamlet,Shakespeare,P-1" "Add Hamlet (patch from Leo)"
c "Marta Lindqvist" marta.l@library.example "Marta Lindqvist" 2025-04-07T10:00:00 "Ulysses,Joyce,C-2" "Add Ulysses"
c "Marta Kowalski" marta.k@library.example "Marta Kowalski" 2025-04-08T10:00:00 "Solaris,Lem,SF-3" "Add Solaris"
