#!/usr/bin/env bash
set -e
git reflog | grep 'Rewrite API reference headings'
tip=$(git reflog --format='%H %gs' | grep 'commit: Rewrite API reference headings' | head -1 | cut -d' ' -f1)
git branch docs/v2-migration "$tip"
