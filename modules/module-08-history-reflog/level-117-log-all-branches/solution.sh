#!/usr/bin/env bash
set -e
c=$(git log --all --format=%H -1 --grep='Cap overtime multiplier')
git branch --contains "$c" --format='%(refname:short)' > found.txt
git log -1 --format=%an "$c" >> found.txt
