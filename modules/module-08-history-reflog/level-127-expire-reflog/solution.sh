#!/usr/bin/env bash
set -e
git reflog expire --expire=now --all
git gc -q --prune=now
