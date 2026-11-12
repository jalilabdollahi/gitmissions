#!/usr/bin/env bash
set -e
sha=$(sed -n 's/^values-prod blob: //p' NOTES.txt)
git update-index --add --cacheinfo 100644,"$sha",charts/values-prod.yaml
git update-index --chmod=+x bin/rotate-certs.sh
git update-index --skip-worktree config/local.env
git commit -qm "Add prod values and make rotate script executable"
git restore charts/values-prod.yaml bin/rotate-certs.sh
