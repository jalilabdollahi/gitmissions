#!/usr/bin/env bash
set -e
git reflog | head -5
git branch rescue/csv-export HEAD@{1}
