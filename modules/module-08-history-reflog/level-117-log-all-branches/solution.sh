#!/usr/bin/env bash
set -e

cat > all-branches.txt <<'EOF'
subjects=4
EOF
git add all-branches.txt
git commit -m "docs: add report"
