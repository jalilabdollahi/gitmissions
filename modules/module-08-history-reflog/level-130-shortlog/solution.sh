#!/usr/bin/env bash
set -e

cat > shortlog.txt <<'EOF'
Alice 2
EOF
git add shortlog.txt
git commit -m "docs: add report"
