#!/usr/bin/env bash
set -e

cat > author-report.txt <<'EOF'
matches=2
EOF
git add author-report.txt
git commit -m "docs: add report"
