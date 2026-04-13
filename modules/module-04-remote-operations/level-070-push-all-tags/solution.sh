#!/usr/bin/env bash
set -e

git tag v1.0
git tag v1.1
git push --tags origin
