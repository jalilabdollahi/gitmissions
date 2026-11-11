#!/usr/bin/env bash
set -e
git reset -q --hard ORIG_HEAD
git config rebase.autoSquash true
GIT_SEQUENCE_EDITOR=true git rebase -q -i main
git push -q --force-with-lease origin feature/ledger-sync
