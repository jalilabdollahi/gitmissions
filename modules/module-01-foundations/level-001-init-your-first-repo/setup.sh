#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"

mkdir -p project
cd project
cat > README.md <<'EOF'
# My Project
EOF

cat > main.py <<'EOF'
print('hello')
EOF

cat > .gitignore <<'EOF'
__pycache__/
*.pyc
EOF
