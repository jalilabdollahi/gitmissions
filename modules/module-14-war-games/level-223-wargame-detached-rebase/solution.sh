#!/usr/bin/env bash
set -e
git rebase --abort
git rebase -q --onto main feature/a feature/b
git push -q --force-with-lease origin feature/b
git push -q origin --delete feature/a
git branch -q -D feature/a
