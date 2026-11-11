#!/usr/bin/env bash
set -e
cat > ../origin.git/hooks/pre-receive <<'HOOK'
#!/bin/sh
# Server-side policy: every new commit must have an @acme-finance.com author address
zero=0000000000000000000000000000000000000000
while read old new ref; do
  [ "$new" = "$zero" ] && continue          # branch deletion
  if [ "$old" = "$zero" ]; then
    range="$new --not --all"                # new branch: only commits not yet in any ref
  else
    range="$old..$new"
  fi
  bad=$(git log --format='%h %ae' $range | grep -v '@acme-finance\.com$' || true)
  if [ -n "$bad" ]; then
    echo "pre-receive: rejected $ref, commits with a non-company author address:" >&2
    echo "$bad" | sed 's/^/  /' >&2
    exit 1
  fi
done
exit 0
HOOK
chmod +x ../origin.git/hooks/pre-receive
