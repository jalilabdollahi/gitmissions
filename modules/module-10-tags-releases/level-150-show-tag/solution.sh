#!/usr/bin/env bash
set -e

cat > show-tag.txt <<'EOF'
tag=v1.0
EOF
git add show-tag.txt
git commit -m "docs: add report"
