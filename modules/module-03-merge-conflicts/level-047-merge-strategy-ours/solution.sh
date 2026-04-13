#!/usr/bin/env bash
set -e

git switch main
git merge -s ours feature/merge
