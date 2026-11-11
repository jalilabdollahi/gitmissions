#!/usr/bin/env bash
set -e
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
# Announce how many files are about to be committed
n=$(git diff --cached --name-only | wc -l | tr -d ' ')
echo "[ledger-guard] $n file(s) staged"
exit 0
HOOK
chmod +x .git/hooks/pre-commit
