#!/usr/bin/env bash
set -e
git log --no-merges --format='- %s' v2.3.0..main > CHANGELOG-draft.md
