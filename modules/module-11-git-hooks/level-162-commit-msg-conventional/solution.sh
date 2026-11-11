#!/usr/bin/env bash
set -e
cat > .git/hooks/commit-msg <<'HOOK'
#!/bin/sh
# Conventional Commits: type(scope)!: subject
subject=$(grep -v '^#' "$1" | sed -n '1p')
case "$subject" in
  "Merge "*|"Revert \""*) exit 0 ;;
esac
pattern='^(feat|fix|docs|chore|refactor|test)(\([a-z0-9_-]+\))?!?: .+'
if ! printf '%s\n' "$subject" | grep -Eq "$pattern"; then
  echo "commit-msg: '$subject' does not follow Conventional Commits" >&2
  echo "  expected: type(scope): subject   with type one of feat|fix|docs|chore|refactor|test" >&2
  exit 1
fi
exit 0
HOOK
chmod +x .git/hooks/commit-msg
