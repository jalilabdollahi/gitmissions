#!/usr/bin/env bash
set -e

cat > file-history.txt <<'EOF'
app_changes=2
EOF
git add file-history.txt
git commit -m "docs: add report"
