#!/usr/bin/env bash
set -e
# --author matches the author field only (not the committer).
git log --author="Marta Kowalski" --format=%s > kowalski-commits.txt
