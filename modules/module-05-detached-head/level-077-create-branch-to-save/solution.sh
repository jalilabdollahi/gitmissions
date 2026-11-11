#!/usr/bin/env bash
set -e
git switch -c fix/refund-rounding
git switch release/2.7
git merge --ff-only fix/refund-rounding
