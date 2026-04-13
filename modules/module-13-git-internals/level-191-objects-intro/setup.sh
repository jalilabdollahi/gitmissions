#!/usr/bin/env bash
set -e
SANDBOX="$1"
cd "$SANDBOX"


git init -b main
git config user.email "player@gitmissions.local"
git config user.name "Player"

cat > app.txt <<'EOF'
version=1
EOF

git add app.txt

GIT_AUTHOR_NAME='Alice' GIT_AUTHOR_EMAIL='alice@example.com' GIT_AUTHOR_DATE='2024-01-10T10:00:00' GIT_COMMITTER_DATE='2024-01-10T10:00:00' git commit -m "Initial scaffold"

printf 'version=2
' > app.txt

git add app.txt

GIT_AUTHOR_NAME='Bob' GIT_AUTHOR_EMAIL='bob@example.com' GIT_AUTHOR_DATE='2024-02-10T10:00:00' GIT_COMMITTER_DATE='2024-02-10T10:00:00' git commit -m "Bump version"

cat > RELEASE.md <<'EOF'
ready
EOF

git add RELEASE.md

GIT_AUTHOR_NAME='Alice' GIT_AUTHOR_EMAIL='alice@example.com' GIT_AUTHOR_DATE='2024-03-10T10:00:00' GIT_COMMITTER_DATE='2024-03-10T10:00:00' git commit -m "Add release notes"
