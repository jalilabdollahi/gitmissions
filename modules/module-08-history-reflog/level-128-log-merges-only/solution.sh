#!/usr/bin/env bash
set -e
git log --merges --format=%s > merge-report.txt
