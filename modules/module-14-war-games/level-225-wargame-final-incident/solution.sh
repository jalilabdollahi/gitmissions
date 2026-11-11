#!/usr/bin/env bash
set -e
git switch -q -c release/3.0 origin/release/3.0
git merge -q --no-edit 'origin/release/3.0@{1}' >/dev/null
hf=$(git reflog --format='%H %gs' HEAD | awk '/commit: tls: add hsts and bump to 3.0.1/ {print $1; exit}')
git merge "$hf" >/dev/null 2>&1 || true
printf 'apiVersion: v2\nname: orbit\nversion: 3.0.2\n' > Chart.yaml
printf 'appVersion: 3.0.2\ntls:\n  minVersion: "1.3"\n  ciphers: modern\nreplicas: 3\nhsts: true\n' > deploy/values.yaml
git rm -q artifacts.txt
sh ./check.sh
git add -A
git commit -q --no-edit
git push -q origin release/3.0
