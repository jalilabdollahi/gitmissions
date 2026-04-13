#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > README.md <<'EOF'
# Sandbox
EOF

git add README.md

git commit -m "Initial scaffold"

git add . >/dev/null 2>&1 || true

cat > app.txt <<'EOF'
app=v2
EOF

cat > notes.txt <<'EOF'
leave me alone
EOF

cat > draft.txt <<'EOF'
also leave me alone
EOF
