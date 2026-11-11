#!/usr/bin/env bash
set -e
# Remove from the index only; the files stay on disk.
git rm --cached .env local.db
git commit -m "Stop tracking local files"
