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
git switch -q -c develop
printf 'class Client:\n    def __init__(self, host):\n        self.host = host\n\n' > client.py
git add -A; ci Nia nia@redis-lite.dev "2025-09-01T09:00:00" "client: connection class"
printf 'def ping(c):\n    return True\n' > commands.py
git add -A; ci Nia nia@redis-lite.dev "2025-09-02T09:00:00" "client: ping command"
printf '# redis-lite\n' > README.md
git add -A; ci Nia nia@redis-lite.dev "2025-09-03T09:00:00" "docs: readme"
printf 'def pipeline(c):\n    return []\n' >> client.py
git add -A; ci Kai kai@redis-lite.dev "2025-09-04T09:00:00" "client: add pipeline support"
printf 'def retry_on_timeout(c):\n    return 3\n' >> client.py
git add -A; ci Lena lena@redis-lite.dev "2025-09-05T09:00:00" "client: retry on timeout"
printf 'def set_ttl(c, key, seconds):\n    return seconds\n' >> client.py
git add -A; ci Kai kai@redis-lite.dev "2025-09-06T09:00:00" "client: ttl helpers"
git tag -a v0.4.0 -m "v0.4.0"
printf 'def scan_iter(c):\n    yield from []\n' > scan.py
git add -A; ci Nia nia@redis-lite.dev "2025-09-08T09:00:00" "client: scan iterator"
printf '# Changelog\n- scan iterator\n' > CHANGELOG.md
git add -A; ci Nia nia@redis-lite.dev "2025-09-09T09:00:00" "docs: update changelog"
git push -q origin develop --tags 2>/dev/null
GIT_SEQUENCE_EDITOR="sed -i.bak '1,3s/^pick/drop/'" git rebase -q -i HEAD~5 >/dev/null 2>&1
git push -q --force origin develop 2>/dev/null
