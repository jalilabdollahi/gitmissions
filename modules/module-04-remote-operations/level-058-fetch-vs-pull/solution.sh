#!/usr/bin/env bash
set -e
git fetch origin
git log --reverse --format=%s main..origin/main > incoming.txt
