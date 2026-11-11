#!/usr/bin/env bash
set -e
enabling=$(git log -S'"round_up": true' --format=%H --reverse | head -1)
git switch --detach "$enabling^"
