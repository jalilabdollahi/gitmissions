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

mkdir crypto
printf 'int tls_init(void) { return 1; }\n/* hw rng */\n' > crypto/tls.c
printf 'int main(void) { return 0; }\n' > boot.c
git add -A; ci Odile odile@fw.dev "2025-05-05T10:00:00" "Bootloader with TLS stub"
git switch -q -c vendor/openssl-3.0.14
printf 'int tls_init(void) { return 2; }\n/* hw rng */\n' > crypto/tls.c
printf 'cve-2025-0001 backported\n' > crypto/patches.txt
git add -A; ci Odile odile@fw.dev "2025-05-12T10:00:00" "Import openssl 3.0.14"
git switch -q main
printf 'int tls_init(void) { return 3; }\n/* hw rng */\n' > crypto/tls.c
git add -A; ci Kofi kofi@fw.dev "2025-05-14T10:00:00" "bootloader: enable secure boot"
git switch -q -c scratch-merge
git merge vendor/openssl-3.0.14 >/dev/null 2>&1 || true
printf 'int tls_init(void) { return 3; }\n/* hw rng */\n/* openssl 3.0.14 */\n' > crypto/tls.c
git add -A; ci Kofi kofi@fw.dev "2025-05-20T10:00:00" "scratch merge (offline)"
git tag resolved "$(git rev-parse 'HEAD^{tree}')"
git switch -q main
git branch -q -D scratch-merge
