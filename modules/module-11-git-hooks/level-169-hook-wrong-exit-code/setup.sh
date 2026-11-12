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
mkdir reports
printf 'quarter,filings\n2025Q1,14\n' > reports/filings.csv
ci Dana "2025-07-01T09:00:00" "Regulatory filings summary"
git switch -q -c release/2025.1
printf 'quarter,filings\n2025Q2,17\n' > reports/q2.csv
ci Dana "2025-07-02T09:00:00" "Add Q2 filings to the release"
git switch -q main
printf 'quarter,filings,late\n2025Q1,14,2\n' > reports/filings.csv
ci Ravi "2025-07-03T09:00:00" "Track late filings"
git switch -q -c feature/late-ratio
printf 'ratio = late / filings\n' > reports/ratio.txt
ci Ravi "2025-07-04T09:00:00" "Compute late ratio"
git switch -q main
printf 'Rebasing release branches rewrites published history.\n' > POLICY.txt
ci Dana "2025-07-07T09:00:00" "Write down the rebase policy"
cat > .git/hooks/pre-rebase <<'HOOK'
#!/bin/sh
# pre-rebase <upstream> [<branch being rebased>]
# Policy: release/* branches are published and must never be rebased.
branch="$2"
[ -n "$branch" ] || branch=$(git symbolic-ref --short HEAD)
case "$branch" in
  release/*)
    echo "pre-rebase: release branches must never be rebased"
    exit $?
    ;;
esac
exit 0
HOOK
chmod +x .git/hooks/pre-rebase
