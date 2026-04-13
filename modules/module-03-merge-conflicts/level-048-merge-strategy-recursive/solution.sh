#!/usr/bin/env bash
set -e

git switch main
git merge -Xours feature/merge
