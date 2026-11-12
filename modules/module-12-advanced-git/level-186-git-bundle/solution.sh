#!/usr/bin/env bash
set -e
mkdir -p ../transfer
git bundle create ../transfer/full.bundle --all
git bundle create ../transfer/delta.bundle v1.0..main
