#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

printf 'pool 2.pool.ntp.org iburst\nmakestep 1 3\n' > chrony.conf
printf '# ntp-ops\n' > README.md
git add -A; ci Bea bea@ops.dev "2025-02-03T09:00:00" "Base chrony configuration"
printf 'driftfile /var/lib/chrony/drift\n' >> chrony.conf
git add -A; ci Bea bea@ops.dev "2025-02-05T09:00:00" "Keep a drift file"
git switch -q -c hotfix/ntp
printf 'server ntp1.corp.example iburst  # stratum 1\n' >> chrony.conf
git add -A; ci Bea bea@ops.dev "2025-02-10T09:00:00" "ntp: use internal stratum 1 server"
printf 'makestep 0.1 3\n' >> chrony.conf
git add -A; ci Bea bea@ops.dev "2025-02-10T11:00:00" "ntp: tighten makestep window"
printf '# chrony 4.5 required\n' >> chrony.conf
git add -A; ci Bea bea@ops.dev "2025-02-11T09:00:00" "ntp: pin chrony to 4.5"
git switch -q main
rm .git/refs/heads/hotfix/ntp .git/logs/refs/heads/hotfix/ntp
rmdir .git/refs/heads/hotfix .git/logs/refs/heads/hotfix
printf 'ref: refs/heads/mian\n' > .git/HEAD
