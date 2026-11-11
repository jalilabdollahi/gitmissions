#!/usr/bin/env bash
set -e
git reset -q --hard HEAD^
git merge feature/rate-limit >/dev/null 2>&1 || true
printf 'chain:\n  - auth\n  - ratelimit\n  - cors\n  - compress\n' > gateway.yaml
printf 'routes:\n  - /health\n  - /rotate\n  - /limits\n' > routes.yaml
git add gateway.yaml routes.yaml
git commit -q --no-edit
git merge feature/audit-log >/dev/null 2>&1 || true
printf 'chain:\n  - auth\n  - ratelimit\n  - audit\n  - cors\n  - compress\n' > gateway.yaml
printf 'routes:\n  - /health\n  - /rotate\n  - /limits\n  - /audit\n' > routes.yaml
sh ./check.sh
git add gateway.yaml routes.yaml
git commit -q --no-edit
