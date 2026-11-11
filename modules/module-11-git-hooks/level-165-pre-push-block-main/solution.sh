#!/usr/bin/env bash
set -e
cat > .git/hooks/pre-push <<'HOOK'
#!/bin/sh
# stdin: <local ref> <local sha> <remote ref> <remote sha>
while read local_ref local_sha remote_ref remote_sha; do
  case "$remote_ref" in
    refs/heads/main|refs/heads/release/*)
      echo "pre-push: direct pushes to ${remote_ref#refs/heads/} are blocked; open a pull request" >&2
      exit 1 ;;
  esac
done
exit 0
HOOK
chmod +x .git/hooks/pre-push
