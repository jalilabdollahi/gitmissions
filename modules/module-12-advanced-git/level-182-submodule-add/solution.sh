#!/usr/bin/env bash
set -e
git -c protocol.file.allow=always submodule add ../vpc-module.git modules/vpc
git -C modules/vpc checkout -q v1.2.0
git add modules/vpc
git commit -qm "Add vpc module pinned to v1.2.0"
