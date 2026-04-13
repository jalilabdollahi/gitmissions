#!/usr/bin/env bash
set -e

cat > hooks-report.txt <<'EOF'
hook=understood
EOF
git add hooks-report.txt
git commit -m "docs: add report"
