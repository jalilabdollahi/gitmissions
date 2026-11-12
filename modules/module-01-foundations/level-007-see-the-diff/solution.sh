#!/usr/bin/env bash
set -e
git diff > unstaged.patch
git diff --staged > staged.patch
