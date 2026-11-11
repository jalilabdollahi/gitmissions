#!/usr/bin/env bash
set -e
cat > .git/hooks/prepare-commit-msg <<'HOOK'
#!/bin/sh
# Prefix the message with the ticket key found in the branch name (feature/FIN-204-rounding -> "FIN-204: ")
file="$1"
source="$2"
case "$source" in
  merge|squash) exit 0 ;;
esac
branch=$(git symbolic-ref --short HEAD 2>/dev/null) || exit 0
ticket=$(printf '%s' "$branch" | grep -oE 'FIN-[0-9]+' | head -1)
[ -n "$ticket" ] || exit 0
if ! head -1 "$file" | grep -q "^$ticket: "; then
  sed -i.bak "1s/^/$ticket: /" "$file"
  rm -f "$file.bak"
fi
exit 0
HOOK
chmod +x .git/hooks/prepare-commit-msg
