#!/usr/bin/env bash
set -e

cat > date-report.txt <<'EOF'
matches=2
EOF
git add date-report.txt
git commit -m "docs: add report"
