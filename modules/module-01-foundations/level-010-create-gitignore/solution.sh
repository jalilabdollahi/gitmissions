#!/usr/bin/env bash
set -e
cat > .gitignore <<'EOF'
# secrets
.env
# python bytecode
__pycache__/
# logs (but keep logs/.gitkeep, which is tracked)
*.log
# build output
dist/
EOF
git add .gitignore
git commit -m "Add .gitignore"
