#!/usr/bin/env bash
set -e

git restore --staged debug.log
git commit -m "fix: commit app only"
rm -f debug.log
git restore --staged debug.log >/dev/null 2>&1 || true
