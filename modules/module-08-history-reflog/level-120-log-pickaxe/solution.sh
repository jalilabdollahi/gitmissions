#!/usr/bin/env bash
set -e

cat > pickaxe.txt <<'EOF'
matches=1
EOF
git add pickaxe.txt
git commit -m "docs: add report"
