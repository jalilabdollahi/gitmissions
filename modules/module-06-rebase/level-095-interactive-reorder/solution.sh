#!/usr/bin/env bash
set -e
# swap the first two todo lines
GIT_SEQUENCE_EDITOR="sed -i.bak -e '1{h;d;}' -e '2{G;}'" git rebase -i main
