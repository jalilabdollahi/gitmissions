#!/usr/bin/env bash
set -e
git grep -n -e '^<<<<<<<' -e '^=======$' -e '^>>>>>>>' || true
ttl=$(grep -o 'TTL at [0-9]*' docs/ops.md | grep -o '[0-9]*')
cat > settings.py <<EOF
DEBUG = False
CACHE_TTL = $ttl
ALLOWED_HOSTS = ["brief.example"]
LOG_LEVEL = "INFO"
EOF
git commit -am "Fix leftover conflict markers in settings.py"
