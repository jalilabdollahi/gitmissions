#!/usr/bin/env bash
set -e
old=$(git rev-parse main)
new=$(GIT_AUTHOR_NAME="Release Bot" GIT_AUTHOR_EMAIL=release-bot@fw.dev GIT_AUTHOR_DATE="2025-06-01T12:00:00+0000" \
  git commit-tree resolved -p main -p vendor/openssl-3.0.14 -m "Merge vendor/openssl-3.0.14 with offline resolution")
git update-ref -m "merge: vendor/openssl-3.0.14" refs/heads/main "$new" "$old"
git reset -q --hard
