#!/usr/bin/env bash
set -e
git log --pretty=format:'%h | %an | %s' > changelog.txt
