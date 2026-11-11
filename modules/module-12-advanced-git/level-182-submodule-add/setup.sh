#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

G="git -c protocol.file.allow=always"
mkdir remotes .scratch
git init -q --bare -b main remotes/vpc-module.git
git init -q --bare -b main remotes/infra-live.git
git clone -q remotes/vpc-module.git .scratch/vpc 2>/dev/null
cd .scratch/vpc
git config user.name Setup; git config user.email setup@infra.dev; git config commit.gpgsign false
n=0
for v in 1.0.0 1.1.0 1.2.0 1.3.0; do
  n=$((n+1))
  printf 'variable "cidr" {\n  default = "10.%s.0.0/16"\n}\n' "${v%%.*}${v#*.}" > variables.tf
  printf 'resource "aws_vpc" "this" {\n  cidr_block = var.cidr\n  # module %s\n}\n' "$v" > main.tf
  git add -A; ci Rosa rosa@infra.dev "2025-02-0${n}T10:00:00" "Release $v"; git tag "v$v"
done
printf 'resource "aws_flow_log" "this" {}\n' >> main.tf
git add -A; ci Rosa rosa@infra.dev "2025-03-01T10:00:00" "WIP: flow logs (unreviewed)"
git push -q origin main --tags 2>/dev/null
cd "$SANDBOX"; rm -rf .scratch
git clone -q remotes/infra-live.git infra-live 2>/dev/null
cd infra-live
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
printf 'terraform {\n  required_version = ">= 1.6"\n}\n' > main.tf
git add -A; ci Rosa rosa@infra.dev "2025-03-02T10:00:00" "Root module skeleton"
git push -q origin main 2>/dev/null
