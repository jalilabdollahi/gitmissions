#!/usr/bin/env bash
set -e
cat > ../origin.git/hooks/update <<'HOOK'
#!/bin/sh
# update <refname> <old> <new>   (runs once per updated ref)
refname="$1"; old="$2"; new="$3"
zero=0000000000000000000000000000000000000000
case "$refname" in
  refs/tags/*)
    if [ "$old" != "$zero" ]; then
      echo "update: tag ${refname#refs/tags/} already exists and is immutable (no move, no delete)" >&2
      exit 1
    fi ;;
esac
exit 0
HOOK
chmod +x ../origin.git/hooks/update
