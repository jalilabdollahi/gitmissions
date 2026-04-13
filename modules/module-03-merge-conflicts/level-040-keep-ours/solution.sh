#!/usr/bin/env bash
set -e

cat > app.txt <<'EOF'
value=main
EOF
git add app.txt
git commit -m "Resolve merge conflict"
