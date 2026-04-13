#!/usr/bin/env bash
set -e

cat > diff-report.txt <<'EOF'
changed_line=version=2
EOF
git add diff-report.txt
git commit -m "docs: add report"
