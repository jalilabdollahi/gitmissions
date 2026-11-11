#!/usr/bin/env bash
set -e
GIT_SEQUENCE_EDITOR="sed -i.bak -e '3s/^pick/fixup/'" git rebase -i main
