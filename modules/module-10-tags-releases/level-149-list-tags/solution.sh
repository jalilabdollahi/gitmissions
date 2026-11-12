#!/usr/bin/env bash
set -e
git tag --sort=-v:refname | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | head -1 > latest-stable.txt
git tag -l 'v1.*' --sort=v:refname > v1-tags.txt
