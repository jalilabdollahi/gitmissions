#!/usr/bin/env bash
set -e
git restore --staged secrets.env
git status --short
