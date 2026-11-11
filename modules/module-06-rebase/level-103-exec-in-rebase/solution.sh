#!/usr/bin/env bash
set -e
# Detect: this stops at the first failing commit, then we abort
GIT_SEQUENCE_EDITOR=true git rebase -i --exec "sh test.sh" main || git rebase --abort
# Repair: move the fix next to the broken commit and fold it in
GIT_SEQUENCE_EDITOR='f() { awk "{a[NR]=\$0} END{print a[1]; print a[2]; sub(/^pick/,\"fixup\",a[4]); print a[4]; print a[3]; for(i=5;i<=NR;i++) print a[i]}" "$1" > "$1.new" && mv "$1.new" "$1"; }; f' git rebase -i main
