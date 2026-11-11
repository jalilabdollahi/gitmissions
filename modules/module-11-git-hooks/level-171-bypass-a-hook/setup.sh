#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config core.hooksPath .git/hooks

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'bracket1=10\nbracket2=15\nbracket3=18\nbracket4=30\n' > payroll.conf
printf '# Payroll config\nRead by the monthly payroll run.\n' > README.md
ci Dana "2025-12-01T09:00:00" "Payroll tax brackets for 2025"
printf 'Payroll freeze until 2025-12-31\n' > FREEZE
ci Dana "2025-12-10T09:00:00" "Start the year-end payroll freeze"
cat > .git/hooks/pre-commit <<'HOOK'
#!/bin/sh
# Change freeze: no commits while a FREEZE file exists
if [ -f FREEZE ]; then
  echo "pre-commit: $(head -1 FREEZE); commits are blocked" >&2
  exit 1
fi
exit 0
HOOK
chmod +x .git/hooks/pre-commit
git hash-object .git/hooks/pre-commit > .git/gm-hook-sum
