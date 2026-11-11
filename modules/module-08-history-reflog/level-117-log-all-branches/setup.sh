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
mkdir -p rates
printf 'regular,1.0\novertime,1.5\ncontractor_overtime,2.0\n' > rates/multipliers.csv
printf 'def gross(hours, rate, mult):\n    return hours * rate * mult\n' > payroll.py
ci Dana "2025-04-01T09:00:00" "Initial payroll calculator"
printf 'holiday,2.5\n' >> rates/multipliers.csv
ci Dana "2025-04-02T09:30:00" "Add holiday multiplier"

git switch -q -c feature/overtime-report
printf 'def overtime_hours(week):\n    return max(0, sum(week) - 40)\n' > report.py
ci Mei "2025-04-03T13:00:00" "Report overtime hours per contractor"

git switch -q main
git switch -q -c bugfix/holiday-pay
sed -i.bak 's/^holiday,2.5/holiday,2.0/' rates/multipliers.csv && rm rates/multipliers.csv.bak
ci Tom "2025-04-04T15:10:00" "Cap holiday multiplier at 2.0"

git switch -q main
git switch -q -c hotfix/ot-cap
sed -i.bak 's/^contractor_overtime,2.0/contractor_overtime,1.5/' rates/multipliers.csv && rm rates/multipliers.csv.bak
ci "Ravi Menon" "2025-04-05T08:45:00" "Cap overtime multiplier at 1.5 for contractors"

git switch -q main
printf '# Payroll\nRuns weekly.\n' > README.txt
ci Dana "2025-04-07T09:00:00" "Document the weekly run"
