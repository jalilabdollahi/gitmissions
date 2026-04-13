#!/usr/bin/env bash
set -e

git switch main
git merge --no-ff feature/login
