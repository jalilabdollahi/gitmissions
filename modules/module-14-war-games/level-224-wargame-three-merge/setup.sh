#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

printf 'chain:\n  - cors\n  - compress\n' > gateway.yaml
printf 'routes:\n  - /health\n' > routes.yaml
cat > check.sh <<'EOF'
#!/bin/sh
# validates the plugin chain and routes
cd "$(dirname "$0")"
if grep -rqE '^(<<<<<<<|=======|>>>>>>>)' gateway.yaml routes.yaml; then echo "conflict markers present"; exit 1; fi
a=$(grep -n -- '- auth' gateway.yaml | cut -d: -f1)
r=$(grep -n -- '- ratelimit' gateway.yaml | cut -d: -f1)
u=$(grep -n -- '- audit' gateway.yaml | cut -d: -f1)
if [ -z "$a" ] || [ -z "$r" ] || [ -z "$u" ] || [ "$a" -ge "$r" ] || [ "$r" -ge "$u" ]; then echo "chain must be auth, ratelimit, audit"; exit 1; fi
for p in /health /rotate /limits /audit; do grep -q -- "$p" routes.yaml || { echo "missing route $p"; exit 1; }; done
echo "gateway config ok"
EOF
chmod +x check.sh
git add -A; ci Greer greer@gw.dev "2026-02-02T09:00:00" "Gateway config with plugin chain"
mkf() { # branch plugin route date author
  git switch -q -c "feature/$1" main
  printf 'chain:\n  - %s\n  - cors\n  - compress\n' "$2" > gateway.yaml
  printf 'routes:\n  - /health\n  - %s\n' "$3" > routes.yaml
  git add -A; ci "$5" "$5@gw.dev" "$4" "$1: add $2 plugin"
  git switch -q main
}
mkf auth-rotation auth /rotate 2026-02-05T09:00:00 Aiden
mkf rate-limit ratelimit /limits 2026-02-06T09:00:00 Bela
mkf audit-log audit /audit 2026-02-07T09:00:00 Cyra
git switch -q -c release/2026.03 main
GIT_AUTHOR_NAME=Greer GIT_AUTHOR_EMAIL=greer@gw.dev GIT_COMMITTER_NAME=Greer GIT_COMMITTER_EMAIL=greer@gw.dev GIT_AUTHOR_DATE="2026-02-10T09:00:00" GIT_COMMITTER_DATE="2026-02-10T09:00:00" git merge -q --no-ff feature/auth-rotation -m "Merge feature/auth-rotation" >/dev/null
git merge feature/rate-limit >/dev/null 2>&1 || true
git add -A
GIT_AUTHOR_NAME=Greer GIT_AUTHOR_EMAIL=greer@gw.dev GIT_COMMITTER_NAME=Greer GIT_COMMITTER_EMAIL=greer@gw.dev GIT_AUTHOR_DATE="2026-02-10T10:00:00" GIT_COMMITTER_DATE="2026-02-10T10:00:00" git commit -q --no-edit
