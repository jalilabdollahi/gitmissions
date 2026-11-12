#!/usr/bin/env bash
set -e
git merge docs tests ci -m "Merge docs, tests and ci into main"
git log --oneline --graph
