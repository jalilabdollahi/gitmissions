#!/usr/bin/env bash
set -e
# -i makes --grep case-insensitive
git log -i --grep=overtime --format=%H > overtime-commits.txt
