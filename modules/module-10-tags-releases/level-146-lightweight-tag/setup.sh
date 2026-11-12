#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf 'def parse_form(path):\n    return {}\n' > filer.py
ci Dana "2025-01-13T09:00:00" "Skeleton for the tax-filing CLI"
printf 'FORMS = ["1040", "schedule-c"]\n' > forms.py
ci Dana "2025-01-14T09:00:00" "List supported tax forms"
git tag v0.8.0
printf 'def validate(form):\n    return True\n' > validate.py
ci Ravi "2025-01-20T09:00:00" "Add form validation"
printf 'DEFAULT_YEAR = 2024\n' > settings.py
ci Ravi "2025-01-21T09:00:00" "Freeze defaults for release candidate"
