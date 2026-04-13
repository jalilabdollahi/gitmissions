#!/usr/bin/env bash
set -e

cat > app.txt <<'EOF'
value=main+feature
EOF
git add app.txt
git commit -m "Resolve merge conflict"
