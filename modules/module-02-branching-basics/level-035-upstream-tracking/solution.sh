#!/usr/bin/env bash
set -e
git push -u origin feature/rsvp
git branch --set-upstream-to=origin/main main
git branch -vv
