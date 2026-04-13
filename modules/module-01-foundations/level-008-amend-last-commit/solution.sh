#!/usr/bin/env bash
set -e

printf 'v1.0 ready
' > notes.md
git add notes.md
git commit --amend -m "docs: release notes"
