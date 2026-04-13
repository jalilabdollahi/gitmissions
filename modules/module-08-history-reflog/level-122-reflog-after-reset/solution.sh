#!/usr/bin/env bash
set -e

git reflog
git checkout HEAD@{1} -- recovered.txt
git add recovered.txt
git commit -m "chore: recover history"
