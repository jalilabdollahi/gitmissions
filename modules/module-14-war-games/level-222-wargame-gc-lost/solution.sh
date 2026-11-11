#!/usr/bin/env bash
set -e
git fetch -q ../mirror.git feature/geo-router:feature/geo-router tag v0.9-geo-beta
git fetch -q ../wei-clone feature/tile-cache:feature/tile-cache
git config gc.pruneExpire 30.days.ago
