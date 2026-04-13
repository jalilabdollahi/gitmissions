#!/usr/bin/env bash
set -e

cat > no-merges.txt <<'EOF'
non_merges=3
EOF
git add no-merges.txt
git commit -m "docs: add report"
