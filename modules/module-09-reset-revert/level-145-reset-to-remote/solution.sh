#!/usr/bin/env bash
set -e
git fetch origin
git branch scratch-backup main
git reset --hard origin/main
