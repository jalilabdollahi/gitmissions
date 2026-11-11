#!/usr/bin/env bash
set -e
git clone --depth 2 "file://$(pwd)/../streamlane.git" ci-checkout
cd ci-checkout
git fetch --deepen 3
