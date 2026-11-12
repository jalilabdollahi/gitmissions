#!/usr/bin/env bash
set -e
cat > .git/hooks/commit-msg <<'HOOK'
#!/bin/sh
# DCO check: every commit message needs a Signed-off-by trailer
msgfile="$1"
if ! grep -q '^Signed-off-by: .* <.*@.*>$' "$msgfile"; then
    echo "commit-msg: missing Signed-off-by trailer (use git commit -s)" >&2
    exit 1
fi
exit 0
HOOK
chmod +x .git/hooks/commit-msg
