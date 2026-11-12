#!/usr/bin/env bash
set -e
git switch feature/shuffle
git stash pop
git commit -am "Add shuffle mode"
