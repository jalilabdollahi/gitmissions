#!/usr/bin/env bash
set -e
git symbolic-ref HEAD refs/heads/main
tip=$(git reflog --format='%H %gs' | awk '/commit: ntp: pin chrony to 4.5/ {print $1; exit}')
git update-ref refs/heads/hotfix/ntp "$tip"
