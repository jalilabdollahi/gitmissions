#!/usr/bin/env bash
set -e
git reflog | head -5
git reset --hard HEAD@{1}
