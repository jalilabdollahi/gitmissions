#!/usr/bin/env bash
set -e
git log --follow --format=%H -- rules/de/vat.yaml > .followed
wc -l < .followed | tr -d ' ' > history-count.txt
tail -1 .followed > first-commit.txt
rm .followed
