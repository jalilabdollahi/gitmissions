#!/usr/bin/env bash
set -e
cat > .git/hooks/commit-msg <<'HOOK'
#!/bin/sh
# $1 is the file holding the commit message
subject=$(grep -v '^#' "$1" | sed -n '1p')
len=$(printf '%s' "$subject" | wc -c | tr -d ' ')
if [ "$len" -lt 10 ]; then
  echo "commit-msg: subject is too short ($len chars, minimum 10)" >&2
  exit 1
fi
case $(printf '%s' "$subject" | tr 'A-Z' 'a-z') in
  wip*)
    echo "commit-msg: WIP commits are not allowed on this repository" >&2
    exit 1 ;;
esac
exit 0
HOOK
chmod +x .git/hooks/commit-msg
