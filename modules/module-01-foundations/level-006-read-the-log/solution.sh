#!/usr/bin/env bash
set -e

cat > log-report.txt <<'EOF'
latest=Add release notes
EOF
git add log-report.txt
git commit -m "docs: add report"
