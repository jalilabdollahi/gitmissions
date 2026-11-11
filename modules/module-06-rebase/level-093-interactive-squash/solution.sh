#!/usr/bin/env bash
set -e
GIT_SEQUENCE_EDITOR="sed -i.bak -e '2s/^pick/squash/' -e '3s/^pick/squash/'" git rebase -i main
