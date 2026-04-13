#!/usr/bin/env bash
set -e

git -c protocol.file.allow=always submodule add ./lib.git vendor/lib
