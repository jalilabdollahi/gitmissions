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
printf 'bank,endpoint\nalpha,/v1/alpha\n' > connectors.csv
ci Dana "2024-01-08T09:00:00" "Connector for Alpha Bank"
git tag v1.2.0
printf 'beta,/v1/beta\n' >> connectors.csv
ci Dana "2024-02-12T09:00:00" "Connector for Beta Bank"
git tag v1.9.0
printf 'gamma,/v1/gamma\n' >> connectors.csv
ci Ravi "2024-03-04T09:00:00" "Connector for Gamma Bank"
git tag v1.10.0
git tag v1.9.1
printf 'delta,/v1/delta\n' >> connectors.csv
ci Ravi "2024-04-15T09:00:00" "Connector for Delta Bank"
git tag v1.10.1-rc1
git tag release-2024Q2
printf 'epsilon,/v2/epsilon\n' >> connectors.csv
ci Mei "2024-05-20T09:00:00" "Connector for Epsilon Bank on the v2 API"
git tag v2.0.0-rc1
git tag v0.9.0 HEAD~4
