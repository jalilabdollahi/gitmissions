#!/usr/bin/env bash
set -e
git -c protocol.file.allow=always submodule update --init --recursive
git config submodule.recurse true
