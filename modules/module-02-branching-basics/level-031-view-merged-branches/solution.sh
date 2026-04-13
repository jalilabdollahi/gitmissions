#!/usr/bin/env bash
set -e

cat > merged.txt <<'EOF'
feature/merged
EOF
git add merged.txt
git commit -m "docs: record branches"
