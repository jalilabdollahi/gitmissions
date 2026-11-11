#!/usr/bin/env bash
set -e
git rebase --abort
git branch backup/survey-export
