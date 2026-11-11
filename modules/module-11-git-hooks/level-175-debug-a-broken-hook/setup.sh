#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
git config core.hooksPath .git/hooks

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
mkdir evidence
printf 'case,control,evidence_file\nC-17,access-review,evidence/c17.pdf\n' > evidence/index.csv
printf '# Audit evidence toolkit\nCommits must carry a DCO sign-off.\n' > README.md
ci Dana "2025-10-06T09:00:00" "Audit evidence index"
cat > .git/hooks/commit-msg <<'HOOK'
#!/usr/bin/enb sh
# DCO check: every commit message needs a Signed-off-by trailer
msgfile="$2"
if grep -q '^Signed-off-by: .* <.*@.*>$' "$msgfile"; then
    echo "commit-msg: missing Signed-off-by trailer (use git commit -s)" >&2
    exit 1
fi
exit 0
HOOK
chmod 644 .git/hooks/commit-msg
