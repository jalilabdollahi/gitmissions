#!/usr/bin/env bash
set -e
git for-each-ref --format='%(taggername)' refs/tags/v3.2.0 > tagger.txt
git rev-list -n 1 v3.2.0 > target.txt
git tag -l v3.2.0 --format='%(contents:subject)' > note.txt
