#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

G="git -c protocol.file.allow=always"
mkdir remotes .scratch
git init -q --bare -b main remotes/jsonnet-libs.git
git init -q --bare -b main remotes/observability.git
git clone -q remotes/jsonnet-libs.git .scratch/libs 2>/dev/null
( cd .scratch/libs
  git config user.name Setup; git config user.email setup@obs.dev; git config commit.gpgsign false
  printf 'local g = {};\ng\n' > grafana.libsonnet; printf 'local p = {};\np\n' > panels.libsonnet; printf 'VERSION=0.6.0\n' > VERSION
  git add -A; ci Ines ines@obs.dev "2024-09-01T10:00:00" "initial libs"
  printf 'local g = { dashboard: {} };\ng\n' > grafana.libsonnet; printf 'local p = { graph: {}, stat: {} };\np\n' > panels.libsonnet; printf 'VERSION=0.7.2\n' > VERSION
  git add -A; ci Ines ines@obs.dev "2024-11-12T10:00:00" "release 0.7.2"; git tag v0.7.2
  printf 'local g = { v2: true };\ng\n' > grafana.libsonnet; printf 'VERSION=0.9.0\n' > VERSION
  git add -A; ci Ines ines@obs.dev "2025-02-02T10:00:00" "new layout 0.9.0"
  git push -q origin main --tags 2>/dev/null )
git clone -q remotes/observability.git observability 2>/dev/null
cd observability
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir dashboards; printf '{ title: "latency" }\n' > dashboards/latency.jsonnet
$G submodule add -q ../jsonnet-libs.git third_party/jsonnet-libs 2>/dev/null
git -C third_party/jsonnet-libs checkout -q v0.7.2
git add -A; ci Ines ines@obs.dev "2025-02-10T10:00:00" "Dashboards with jsonnet-libs v0.7.2"
git push -q origin main 2>/dev/null
rm -rf ../.scratch
