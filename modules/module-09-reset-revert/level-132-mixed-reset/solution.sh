#!/usr/bin/env bash
set -e
git reset HEAD~1
git add rules/us_ca.py
git commit -q -m "Add California sales tax rule"
