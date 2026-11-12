#!/usr/bin/env bash
set -e
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
# Block newly added debugger statements in Python files (existing lines are not our concern)
if git diff --cached -U0 --diff-filter=ACM -- '*.py' \
   | grep -E '^\+[^+]' \
   | grep -Eq 'breakpoint\(\)|pdb\.set_trace|import pdb'; then
  echo "pre-commit: debugger statement found in staged Python changes" >&2
  exit 1
fi
exit 0
HOOK
chmod +x .git/hooks/pre-commit
