#!/usr/bin/env bash
set -e
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
# Refuse to commit environment files such as prod.env or config/live.env
bad=$(git diff --cached --name-only --diff-filter=ACMR | grep -E '\.env$' || true)
if [ -n "$bad" ]; then
  echo "pre-commit: refusing to commit environment files:" >&2
  echo "$bad" | sed 's/^/  /' >&2
  exit 1
fi
exit 0
HOOK
chmod +x .git/hooks/pre-commit
