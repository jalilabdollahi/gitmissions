#!/usr/bin/env bash
set -e
git switch -c feature/vaccination-flag
git commit -m "Add vaccinated column to pets"
