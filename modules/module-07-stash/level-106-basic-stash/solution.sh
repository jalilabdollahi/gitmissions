#!/usr/bin/env bash
set -e
git stash push -m "WIP waitlist promotion"
printf 'Reservation confirmed\n' > labels.txt
git commit -am "Fix typo in booking label"
