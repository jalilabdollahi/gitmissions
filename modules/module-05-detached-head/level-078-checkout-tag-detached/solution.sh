#!/usr/bin/env bash
set -e
git switch --detach v1.8.0
sh build.sh
