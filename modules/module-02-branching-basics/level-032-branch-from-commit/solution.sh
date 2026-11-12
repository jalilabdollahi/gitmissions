#!/usr/bin/env bash
set -e
rel=$(git log --format=%h --grep='Ship v1.4 data release')
git switch -c hotfix/station-17 "$rel"
sed -i.bak 's/^17,Harbor Gate,.*/17,Harbor Gate,53.3446,-6.2287/' stations.csv && rm stations.csv.bak
git commit -am "Correct coordinates of station 17"
