#!/usr/bin/env bash
set -e

git switch feature/rebase
git rebase --onto main HEAD~1 HEAD
