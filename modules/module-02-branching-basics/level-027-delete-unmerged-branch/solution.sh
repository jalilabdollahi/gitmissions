#!/usr/bin/env bash
set -e
# The safe delete refuses because the commits are not merged anywhere:
git branch -d experiment/neon-theme || true
# Force it, and keep the abbreviated hash Git prints ("was abc1234") for the record.
git branch -D experiment/neon-theme | sed -n 's/.*was \([0-9a-f]*\)).*/\1/p' > deleted-tip.txt
