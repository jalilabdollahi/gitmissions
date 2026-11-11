#!/usr/bin/env bash
set -e
a=$(git log --format=%h --grep='Plan wedding')
b=$(git log --format=%h --grep='Add Emil')
git diff --name-only "$a" "$b" > changed-files.txt
