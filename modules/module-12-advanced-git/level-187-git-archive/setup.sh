#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

mkdir docsite && cd docsite
git init -q -b main
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
mkdir -p docs/api docs/guide tests .github/workflows design
printf 'tests/ export-ignore\n.github/ export-ignore\ndesign/ export-ignore\n.gitattributes export-ignore\n' > .gitattributes
printf 'dist/\n' > .gitignore
printf 'site_name: Orbit SDK\nnav: [guide, api]\n' > mkdocs.yml
printf '# Orbit SDK\nGetting started with the SDK.\n' > docs/index.md
printf '# Auth API\nPOST /token\n' > docs/api/auth.md
printf '# Users API\nGET /users/{id}\n' > docs/api/users.md
printf '# Install\npip install orbit-sdk\n' > docs/guide/install.md
printf '#!/bin/sh\ngrep -rq "Orbit" docs\n' > tests/test_links.sh
printf 'on: push\njobs: {docs: {runs-on: ubuntu-latest}}\n' > .github/workflows/ci.yml
printf 'BANNER-SOURCE-v1\n' > design/banner.psd
git add -A; ci Tessa tessa@orbit-sdk.dev "2025-04-01T10:00:00" "Docs site for the Orbit SDK"
printf '# Orders API\nGET /orders\n' > docs/api/orders.md
printf '# 1.4\n- orders endpoint\n' > docs/changelog.md
git add -A; ci Tessa tessa@orbit-sdk.dev "2025-04-15T10:00:00" "Document the orders endpoint for 1.4"
git tag -a v1.4 -m "docs 1.4"
printf '# 1.5 (unreleased)\n- webhooks\n' >> docs/changelog.md
printf '# Webhooks API\nPOST /hooks\n' > docs/api/webhooks.md
git add -A; ci Jamal jamal@orbit-sdk.dev "2025-05-02T10:00:00" "Start 1.5 docs: webhooks"
printf 'BANNER-SOURCE-v2\n' > design/banner.psd
git add -A; ci Jamal jamal@orbit-sdk.dev "2025-05-09T10:00:00" "New banner source"
