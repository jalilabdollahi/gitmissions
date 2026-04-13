#!/usr/bin/env bash
set -e

cat > time-syntax.txt <<'EOF'
supported=yes
EOF
git add time-syntax.txt
git commit -m "docs: add report"
