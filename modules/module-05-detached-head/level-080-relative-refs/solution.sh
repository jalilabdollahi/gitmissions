#!/usr/bin/env bash
set -e
git log -1 --format=%s 'main^2'   > refs.txt
git log -1 --format=%s 'main~2'  >> refs.txt
git log -1 --format=%s 'main^2~1' >> refs.txt
git switch --detach 'main^2~1'
