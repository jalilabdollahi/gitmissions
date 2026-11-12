#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main origin.git
git clone -q origin.git work 2>/dev/null
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir charts
subjects=("Initial museum chart" "Add ingress template" "Add resource limits" "Support custom CA bundle" "Add pod disruption budget" "Bump chart to 1.3.0" "Prepare 1.3.1")
n=0
for s in "${subjects[@]}"; do
  n=$((n+1))
  printf 'chart revision %s\n' "$n" > charts/Chart.yaml
  git add -A; ci Cato cato@museum.dev "2025-12-0${n}T09:00:00" "$s"
done
printf 'appVersion: 1.3.1\n' >> charts/Chart.yaml
git add -A; ci Cato cato@museum.dev "2025-12-09T09:00:00" "fix: chart appVersion for 1.3.1"
git tag -a v1.0.0 -m "1.0.0" main~7
git tag -a v1.1.0 -m "1.1.0" main~5
git tag -a v1.2.0 -m "1.2.0" main~3
git tag -a v1.3.0 -m "1.3.0" main~2
git tag v1.3.1 main~1
for i in $(seq 1 36); do git tag "build-$i" "main~$((i % 8))"; done
git push -q origin main --tags 2>/dev/null
for i in 1 2 3; do git tag "build-local-$i" "main~$i"; done
