#!/usr/bin/env bash
set -e
fix=$(git log --format=%h -1 --grep='Reject negative withdrawal')
git switch release/2.4
git cherry-pick -x "$fix"
