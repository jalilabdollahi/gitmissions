#!/usr/bin/env bash
set -e
git fetch -q ../omar-clone refs/heads/main:refs/heads/main 'refs/tags/*:refs/tags/*'
git config receive.denyDeletes true
git config receive.denyNonFastForwards true
