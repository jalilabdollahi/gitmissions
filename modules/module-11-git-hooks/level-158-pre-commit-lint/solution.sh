#!/usr/bin/env bash
set -e
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
# Every staged JSON file must parse. Check the staged blob, not the working copy.
status=0
for f in $(git diff --cached --name-only --diff-filter=ACM | grep '\.json$' || true); do
  if ! git show ":$f" | python3 -m json.tool >/dev/null 2>&1; then
    echo "pre-commit: $f is not valid JSON" >&2
    status=1
  fi
done
exit $status
HOOK
chmod +x .git/hooks/pre-commit
