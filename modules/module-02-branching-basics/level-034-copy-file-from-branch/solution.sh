#!/usr/bin/env bash
set -e
git restore --source=staging -- _config.yml
git add _config.yml
git commit -m "Take site config from staging"
