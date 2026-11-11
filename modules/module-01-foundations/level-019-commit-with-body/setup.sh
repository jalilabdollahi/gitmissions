#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

cat > teatimer.py <<'EOF'
BREW_MINUTES = {"green": 2.5, "black": 4.0, "herbal": 6.0}

def brew_seconds(tea):
    return BREW_MINUTES[tea] * 60.0
EOF
printf '# teatimer\nCounts down your brew.\n' > README.md
git add .
GIT_AUTHOR_NAME=Wen GIT_AUTHOR_EMAIL=wen@teatimer.example GIT_AUTHOR_DATE=2025-10-12T08:00:00 \
GIT_COMMITTER_NAME=Wen GIT_COMMITTER_EMAIL=wen@teatimer.example GIT_COMMITTER_DATE=2025-10-12T08:00:00 \
git commit -q -m "Add brew timer"

cat > teatimer.py <<'EOF'
BREW_MINUTES = {"green": 2.5, "black": 4.0, "herbal": 6.0}

def brew_seconds(tea):
    return round(BREW_MINUTES[tea] * 60)
EOF
git add teatimer.py
