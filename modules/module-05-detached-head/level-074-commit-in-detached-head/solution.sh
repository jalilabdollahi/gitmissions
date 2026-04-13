#!/usr/bin/env bash
set -e

printf 'experiment
' > experiment.txt
git add experiment.txt
git commit -m "Detached experiment"
