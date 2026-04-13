#!/usr/bin/env bash
set -e

git switch main
git merge feature/a feature/b feature/c
