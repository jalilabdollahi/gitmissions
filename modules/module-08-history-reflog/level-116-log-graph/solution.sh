#!/usr/bin/env bash
set -e

cat > graph.txt <<'EOF'
branches=3
EOF
git add graph.txt
git commit -m "docs: add report"
