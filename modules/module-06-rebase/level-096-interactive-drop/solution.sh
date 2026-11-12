#!/usr/bin/env bash
set -e
GIT_SEQUENCE_EDITOR="sed -i.bak -e '2s/^pick/drop/'" git rebase -i main
