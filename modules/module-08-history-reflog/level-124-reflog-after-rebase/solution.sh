#!/usr/bin/env bash
set -e
git reflog -8
git reset --hard ORIG_HEAD
