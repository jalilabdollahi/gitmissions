#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Tomas" GIT_AUTHOR_EMAIL="tomas@mathtutors.example"
export GIT_COMMITTER_NAME="Tomas" GIT_COMMITTER_EMAIL="tomas@mathtutors.example"
export GIT_AUTHOR_DATE="2025-09-05T17:00:00" GIT_COMMITTER_DATE="2025-09-05T17:00:00"

cat > scheduler.py <<'EOF'
import sqlite3
def open_db():
    return sqlite3.connect("local.db")
EOF
printf 'lessons: [algebra, geometry]\n' > lessons.yaml
printf 'SMTP_PASSWORD=hunter2-tutor\n' > .env
printf 'SQLite format 3 (pretend binary)\n' > local.db
git add .
git commit -q -m "Initial tutoring scheduler"

printf '.env\nlocal.db\n' > .gitignore
git add .gitignore
GIT_AUTHOR_DATE="2025-09-06T09:00:00" GIT_COMMITTER_DATE="2025-09-06T09:00:00" git commit -q -m "Add gitignore for local files"
printf 'SQLite format 3 (pretend binary) + 14 new students\n' > local.db
