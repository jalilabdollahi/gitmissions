#!/usr/bin/env bash
set -e
git rebase main || true
git rebase --skip
