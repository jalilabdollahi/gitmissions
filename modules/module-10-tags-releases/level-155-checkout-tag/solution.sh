#!/usr/bin/env bash
set -e
git switch -c support/2.4 v2.4.1
sed -n '1p' schema.sql | sed 's/.*: //' > shipped-schema.txt
