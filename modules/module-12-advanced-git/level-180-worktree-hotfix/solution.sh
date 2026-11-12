#!/usr/bin/env bash
set -e
git worktree add -b hotfix/3.4.1 ../edge-hotfix v3.4.0
cd ../edge-hotfix
sed -i.bak 's/max_request_bytes: 1024$/max_request_bytes: 1048576/' config/limits.yaml
rm config/limits.yaml.bak
git commit -qam "fix: raise max_request_bytes to 1 MiB"
git tag -a v3.4.1 -m "v3.4.1"
