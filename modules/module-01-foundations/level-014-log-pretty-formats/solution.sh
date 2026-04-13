#!/usr/bin/env bash
set -e

cat > pretty-log.txt <<'EOF'
Alice: Add release notes
EOF
git add pretty-log.txt
git commit -m "docs: add report"
