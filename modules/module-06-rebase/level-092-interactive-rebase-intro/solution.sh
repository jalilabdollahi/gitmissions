#!/usr/bin/env bash
set -e
GIT_SEQUENCE_EDITOR="sed -i.bak -e '1s/^pick/reword/'" \
GIT_EDITOR="printf 'Initial commit: scaffold ticket-board\n' >" \
  git rebase -i --root
