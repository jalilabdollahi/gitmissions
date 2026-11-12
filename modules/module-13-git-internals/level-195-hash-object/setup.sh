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

mkdir inbox
printf '# Rotation plan\n1. issue new intermediate\n2. roll leaf certificates\n3. revoke the old chain\n' > inbox/rotation-plan.txt
printf -- '-----BEGIN CERTIFICATE-----\nMIIBchainPLACEHOLDER\n-----END CERTIFICATE-----\n' > inbox/cert-chain.pem
printf -- '-----BEGIN CERTIFICATE-----\nMIIBrootPLACEHOLDER\n-----END CERTIFICATE-----\n' > inbox/ca.crt
printf '# pki-ops\nCertificate rotation runbooks.\n' > README.md
git add README.md
ci Mireille mireille@pki.dev "2025-05-05T09:00:00" "Runbook readme"
