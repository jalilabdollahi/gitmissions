#!/usr/bin/env bash
set -e
git cherry-pick --abort
git cherry-pick "$(git log main --format=%h -1 --grep='Fix leap-day')"
