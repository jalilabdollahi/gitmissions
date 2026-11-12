#!/usr/bin/env bash
set -e
# main has not moved, so a plain merge would fast-forward. --no-ff forces a merge commit.
git merge --no-ff photo-gallery -m "Merge photo gallery"
git log --oneline --graph
