#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@knitgen.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@knitgen.example"; }

printf '# knitgen\nGenerates knitting charts from images.\n' > README.md
who ola; git add . && d 2025-09-01T10:00:00; git commit -q -m "Initial README"

git switch -q -c contributing-style
who maya
cat > CONTRIBUTING.md <<'EOF'
# Contributing to knitgen

## Code style
- Format Python with black before committing.
- Keep functions under 40 lines.
EOF
git add . && d 2025-09-04T10:00:00; git commit -q -m "Add contributing guide: code style"

git switch -q main
who ola
cat > CONTRIBUTING.md <<'EOF'
# Contributing to knitgen

## Commit messages
- Use the imperative mood: "Add chart legend".
- Reference the issue number, e.g. "Fixes #12".
EOF
git add . && d 2025-09-05T10:00:00; git commit -q -m "Add contributing guide: commit messages"
