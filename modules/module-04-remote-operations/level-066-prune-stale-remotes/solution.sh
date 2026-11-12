#!/usr/bin/env bash
set -e
git fetch --prune
git branch -d feature/late-checkout
git config fetch.prune true
