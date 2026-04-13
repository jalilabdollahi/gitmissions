#!/usr/bin/env bash
set -e

cat > status-report.txt <<'EOF'
staged=1
unstaged=1
untracked=1
EOF
git add status-report.txt
git commit -m "docs: add report"
