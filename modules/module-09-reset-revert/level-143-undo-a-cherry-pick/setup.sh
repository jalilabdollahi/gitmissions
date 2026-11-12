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
printf 'def accrue(balance, rate, days):\n    return balance * rate * days / 365\n' > interest.py
printf 'def days_in_year(year):\n    return 365\n' > calendar_days.py
ci Dana "2025-02-03T09:00:00" "Interest accrual baseline"
git switch -q -c release/1.x
printf 'def accrue(balance, rate, days):\n    return round(balance * rate * days / 365, 2)\n' > interest.py
ci Ravi "2025-02-04T10:00:00" "Round accrued interest to cents"
git switch -q main
printf 'class Interest:\n    def __init__(self, rate):\n        self.rate = rate\n\n    def accrue(self, balance, days):\n        return balance * self.rate * days / 365\n' > interest.py
ci Mei "2025-02-05T10:00:00" "Refactor interest into an Interest class"
printf 'def days_in_year(year):\n    leap = year %% 4 == 0 and (year %% 100 != 0 or year %% 400 == 0)\n    return 366 if leap else 365\n' > calendar_days.py
ci Mei "2025-02-06T10:00:00" "Fix leap-day interest accrual"
git switch -q release/1.x
git cherry-pick "$(git log main --format=%h -1 --grep='Refactor interest into')" >/dev/null 2>&1 || true
