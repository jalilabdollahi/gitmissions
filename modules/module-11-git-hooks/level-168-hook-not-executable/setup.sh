#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config core.hooksPath .git/hooks

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'cluster: payments-eu\nreplicas: 4\n' > cluster.yaml
printf '.deploy-target\n' > .gitignore
ci Dana "2025-06-16T09:00:00" "Payments cluster manifest"
git branch staging
cat > .git/hooks/post-checkout <<'HOOK'
#!/bin/sh
# args: <previous HEAD> <new HEAD> <1 if a branch was checked out>
[ "$3" = "1" ] || exit 0
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo detached)
case "$branch" in
  main) target=production ;;
  staging) target=staging ;;
  *) target=dev ;;
esac
echo "$target" > .deploy-target
HOOK
chmod 644 .git/hooks/post-checkout
