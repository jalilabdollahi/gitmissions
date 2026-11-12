#!/usr/bin/env bash
set -e
line='/^OVERDRAFT_FEE_CENTS/'
git blame -w -L "$line,+1" --porcelain parser/fees.py | head -1 | cut -d' ' -f1 > culprit.txt
git log -1 --format=%an "$(cat culprit.txt)" > author.txt
