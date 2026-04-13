#!/usr/bin/env bash
set -e

cat > internals.txt <<'EOF'
object=known
EOF
git add internals.txt
git commit -m "docs: add report"
