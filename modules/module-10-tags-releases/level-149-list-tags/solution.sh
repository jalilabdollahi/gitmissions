#!/usr/bin/env bash
set -e

cat > tags.txt <<'EOF'
tags=2
EOF
git add tags.txt
git commit -m "docs: add report"
