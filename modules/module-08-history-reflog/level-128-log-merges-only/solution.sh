#!/usr/bin/env bash
set -e

cat > merges.txt <<'EOF'
merges=1
EOF
git add merges.txt
git commit -m "docs: add report"
