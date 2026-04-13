#!/usr/bin/env bash
set -e

git switch feature/rebase
git rebase main
