#!/usr/bin/env bash
set -e
git reset -- fixtures/statement_jan_full.csv
git commit -q -m "Parse debit and credit columns"
