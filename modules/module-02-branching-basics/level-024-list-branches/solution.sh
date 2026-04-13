#!/usr/bin/env bash
set -e

cat > branches.txt <<'EOF'
main
feature/ui
bugfix/login
EOF
git add branches.txt
git commit -m "docs: record branches"
