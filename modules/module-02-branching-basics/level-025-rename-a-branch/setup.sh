#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b master
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Dev" GIT_AUTHOR_EMAIL="dev@sciencefair.example" GIT_COMMITTER_NAME="Dev" GIT_COMMITTER_EMAIL="dev@sciencefair.example"
d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }

cat > register.py <<'EOF'
PROJECTS = []

def register(student, title):
    PROJECTS.append((student, title))
    return len(PROJECTS)
EOF
cat > reset.py <<'EOF'
TOKENS = {}

def issue_token(student):
    TOKENS[student] = "tok-" + student
    return TOKENS[student]
EOF
git add . && d 2025-02-03T15:00:00; git commit -q -m "Registration and token helpers"

git switch -q -c fix/pasword-reset
sed -i.bak 's/"tok-" + student/"tok-" + student + "-1h"/' reset.py && rm reset.py.bak
d 2025-02-04T15:00:00; git commit -q -am "Reset token expires after 1 hour"
