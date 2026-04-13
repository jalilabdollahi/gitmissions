#!/usr/bin/env bash
set -e

cat > grep-report.txt <<'EOF'
matches=1
EOF
git add grep-report.txt
git commit -m "docs: add report"
