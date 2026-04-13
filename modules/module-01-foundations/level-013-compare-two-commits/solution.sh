#!/usr/bin/env bash
set -e

cat > compare-report.txt <<'EOF'
difference=version line changed
EOF
git add compare-report.txt
git commit -m "docs: add report"
