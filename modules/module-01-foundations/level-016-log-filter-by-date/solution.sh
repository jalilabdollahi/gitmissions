#!/usr/bin/env bash
set -e
git log --since="2025-03-01 00:00" --until="2025-04-01 00:00" --format=%H > march-commits.txt
