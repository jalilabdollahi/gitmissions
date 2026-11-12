#!/usr/bin/env bash
set -e
GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash main
