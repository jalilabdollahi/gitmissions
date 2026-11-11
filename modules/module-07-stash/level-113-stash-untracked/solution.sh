#!/usr/bin/env bash
set -e
git stash push -u -m "WIP seeding"
git switch release/1.0
