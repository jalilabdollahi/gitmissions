#!/usr/bin/env bash
set -e
cat > .git/hooks/commit-msg <<'HOOK'
#!/bin/sh
# Subjects need a ticket prefix [FIN-123..99999]; [NOTICKET] only on chore/* branches
subject=$(grep -v '^#' "$1" | sed -n '1p')
branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo detached)
case "$subject" in
  "Merge "*) exit 0 ;;
esac
if printf '%s\n' "$subject" | grep -Eq '^\[FIN-[0-9]{3,5}\] .+'; then
  exit 0
fi
if printf '%s\n' "$subject" | grep -Eq '^\[NOTICKET\] .+'; then
  case "$branch" in
    chore/*) exit 0 ;;
  esac
  echo "commit-msg: [NOTICKET] is only allowed on chore/* branches (you are on $branch)" >&2
  exit 1
fi
echo "commit-msg: subject must start with a ticket, e.g. [FIN-1234] Describe the change" >&2
exit 1
HOOK
chmod +x .git/hooks/commit-msg
