#!/usr/bin/env bash
set -e
cat > .git/hooks/post-commit <<'HOOK'
#!/bin/sh
# Notify: append "<short hash> <author>: <subject>" to the notification log
echo "$(git log -1 --format='%h %an: %s')" >> "$(git rev-parse --git-dir)/notifications.log"
exit 0
HOOK
chmod +x .git/hooks/post-commit
