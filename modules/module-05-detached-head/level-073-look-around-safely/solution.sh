#!/usr/bin/env bash
set -e
: > retries.csv
for t in v1.0 v1.5 v2.0; do
  git switch -q --detach "$t"
  printf '%s,%s\n' "$t" "$(sed -n 's/^MAX_RETRIES=//p' settings.ini)" >> retries.csv
done
git switch -q main
