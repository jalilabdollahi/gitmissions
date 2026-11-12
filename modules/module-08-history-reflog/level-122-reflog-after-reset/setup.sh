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
mkdir registry
printf '# name version stage\n' > registry/models.txt
ci Dana "2025-08-04T09:00:00" "Initialize model registry"
printf 'churn-model 0.1.0 dev\n' >> registry/models.txt
ci Ravi "2025-08-05T10:00:00" "Register churn-model 0.1.0"
printf 'fraud-model 1.2.0 dev\n' >> registry/models.txt
ci Ravi "2025-08-06T10:30:00" "Register fraud-model 1.2.0"
sed -i.bak 's/^churn-model 0.1.0 dev/churn-model 0.2.0 staging/' registry/models.txt && rm registry/models.txt.bak
ci Mei "2025-08-07T11:00:00" "Promote churn-model 0.2.0 to staging"
printf 'ltv-model 0.9.0 dev\n' >> registry/models.txt
ci Mei "2025-08-08T11:30:00" "Register ltv-model 0.9.0"
sed -i.bak 's/^fraud-model 1.2.0 dev/fraud-model 1.2.0 production/' registry/models.txt && rm registry/models.txt.bak
ci Dana "2025-08-11T09:30:00" "Promote fraud-model 1.2.0 to production"
git rev-parse HEAD > .git/gm-orig-tip
git reset -q --hard HEAD~3
