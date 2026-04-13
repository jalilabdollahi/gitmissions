#!/usr/bin/env bash
set -e

cat > expire.txt <<'EOF'
command=git reflog expire
EOF
git add expire.txt
git commit -m "docs: add report"
