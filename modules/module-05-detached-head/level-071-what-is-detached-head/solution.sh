#!/usr/bin/env bash
set -e
git rev-parse --short HEAD > detached-at.txt
git for-each-ref --contains HEAD --format='%(refname:short)' refs/heads > contained-in.txt
git switch main
