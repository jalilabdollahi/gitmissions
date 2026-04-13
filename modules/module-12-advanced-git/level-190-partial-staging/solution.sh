#!/usr/bin/env bash
set -e

cat > advanced-report.txt <<'EOF'
done=1
EOF
git add advanced-report.txt
git commit -m "docs: add report"
