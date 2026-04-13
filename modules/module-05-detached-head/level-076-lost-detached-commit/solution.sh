#!/usr/bin/env bash
set -e

git reflog
git branch rescue-detached "$(git reflog --grep-reflog='Detached experiment' --format=%H -n 1)"
