#!/usr/bin/env bash
set -e

git rebase --onto main old-base feature/rebase
git switch feature/rebase
