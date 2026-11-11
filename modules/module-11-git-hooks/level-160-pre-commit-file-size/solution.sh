#!/usr/bin/env bash
set -e
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
# Reject staged files larger than 100 KB (102400 bytes)
limit=102400
rc=0
for f in $(git diff --cached --name-only --diff-filter=ACM); do
  size=$(git cat-file -s ":$f")
  if [ "$size" -gt "$limit" ]; then
    echo "pre-commit: $f is $size bytes (limit $limit)" >&2
    rc=1
  fi
done
exit $rc
HOOK
chmod +x .git/hooks/pre-commit
