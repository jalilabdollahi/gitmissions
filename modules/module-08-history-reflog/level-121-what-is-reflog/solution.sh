#!/usr/bin/env bash
set -e

cat > reflog.txt <<'EOF'
entries>=3
EOF
git add reflog.txt
git commit -m "docs: add report"
