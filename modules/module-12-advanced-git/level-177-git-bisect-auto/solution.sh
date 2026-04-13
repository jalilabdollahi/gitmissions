#!/usr/bin/env bash
set -e

cat > bisect.txt <<'EOF'
bad_commit=known
EOF
git add bisect.txt
git commit -m "docs: add report"
