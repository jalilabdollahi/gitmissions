#!/usr/bin/env bash
set -e
git log -S'tk_live_' --format=%H > .hits
head -1 .hits > removed.txt
tail -1 .hits > introduced.txt
rm .hits
