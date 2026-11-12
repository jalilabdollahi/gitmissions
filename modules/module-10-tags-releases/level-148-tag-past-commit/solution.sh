#!/usr/bin/env bash
set -e
c=$(git log --reverse --format=%H -S'2.1.0' -- VERSION | head -1)
git tag -a v2.1.0 "$c" -m "Release 2.1.0"
