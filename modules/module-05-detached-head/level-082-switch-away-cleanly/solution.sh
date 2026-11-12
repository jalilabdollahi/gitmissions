#!/usr/bin/env bash
set -e
git reflog -3
git restore limits.yaml
git switch -
