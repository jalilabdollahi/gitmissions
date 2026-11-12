#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

c() { # author email date line message
  printf '%s\n' "$4" >> report.md
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" \
  GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" \
  git commit -q -am "$5"
}
touch report.md && git add report.md
GIT_AUTHOR_DATE="2025-03-03T09:00:00" GIT_COMMITTER_DATE="2025-03-03T09:00:00" git commit -q -m "Create empty report for Biology project"
c Lucia lucia@school.example 2025-03-04T16:10:00 "Intro: why wetlands matter" "Write introduction"
c Omar omar@school.example 2025-03-06T12:40:00 "Method: we sampled three ponds" "Add methods section"
c Lucia lucia@school.example 2025-03-09T20:05:00 "Data: pond B had the most frogs" "Add results table"
c Jonas jonas@school.example 2025-03-11T18:30:00 "Chart: frogs per pond" "Insert frog chart"
c Omar omar@school.example 2025-03-12T07:55:00 "Conclusion: protect pond B" "Draft conclusion"
c Lucia lucia@school.example 2025-03-13T22:15:00 "Refs: Smith 2021" "Add bibliography"
