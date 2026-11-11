#!/usr/bin/env bash
set -e
git tag -a v2.0.0 v2.0.o^{commit} -m "Release 2.0.0"
git tag -d v2.0.o
