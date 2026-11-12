#!/usr/bin/env bash
set -e
printf 's\nn\ny\nn\nn\n' | git add -p payroll.py
git commit -qm "fix: round net pay to cents"
printf 'n\ny\ny\n' | git add -p payroll.py
git commit -qm "refactor: rename fmt_row to format_row"
