#!/usr/bin/env bash
set -e
git diff --name-only v5.0 main > drift-files.txt
git rev-list --count v5.0..main > ahead.txt
