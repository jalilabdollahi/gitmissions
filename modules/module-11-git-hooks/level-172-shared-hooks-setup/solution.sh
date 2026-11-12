#!/usr/bin/env bash
set -e
mkdir -p .githooks scripts
cat > .githooks/pre-commit <<'HOOK'
#!/bin/sh
# Team policy: no new markers of unfinished work in Python code
if git diff --cached -U0 -- '*.py' | grep -E '^\+[^+]' | grep -q 'FIXME'; then
  echo "pre-commit: remove the FIXME or open a ticket instead" >&2
  exit 1
fi
exit 0
HOOK
chmod +x .githooks/pre-commit
cat > scripts/install-hooks.sh <<'SH'
#!/bin/sh
# Run once after cloning: use the versioned hooks in .githooks
git config core.hooksPath .githooks
echo "hooks installed from .githooks"
SH
chmod +x scripts/install-hooks.sh
sh scripts/install-hooks.sh
git add .githooks scripts
git commit -q -m "Share the team's hooks through the repository"
