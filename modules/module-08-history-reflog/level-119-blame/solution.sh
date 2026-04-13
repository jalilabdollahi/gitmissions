#!/usr/bin/env bash
set -e

cat > blame.txt <<'EOF'
line1=Alice
EOF
git add blame.txt
git commit -m "docs: add report"
