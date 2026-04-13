#!/usr/bin/env bash
set -e

cat > past-commit.txt <<'EOF'
subject=Initial scaffold
EOF
git add past-commit.txt
git commit -m "docs: add report"
