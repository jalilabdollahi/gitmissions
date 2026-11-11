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
mkdir scripts
printf 'source "amazon-ebs" "web" {\n  provisioner = "scripts/base.sh"\n}\n' > web.pkr.hcl
printf '#!/bin/sh\napt-get update\n' > scripts/base.sh
printf '#!/bin/sh\nsystemctl enable auditd\n' > scripts/harden.sh
cat > test.sh <<'EOF'
#!/bin/sh
# every template must reference scripts that exist
cd "$(dirname "$0")"
miss=0
for s in $(grep -ho 'scripts/[A-Za-z0-9_.-]*\.sh' *.pkr.hcl | sort -u); do
  [ -f "$s" ] || { echo "template references missing $s"; miss=1; }
done
exit $miss
EOF
git add -A; ci Ilse ilse@images.dev "2025-09-01T09:00:00" "Packer templates for base and web"
git push -q origin main 2>/dev/null
printf 'source "amazon-ebs" "web" {\n  provisioner = "scripts/base.sh"\n  provisioner2 = "scripts/hardn.sh"\n}\n' > web.pkr.hcl
git add -A; ci Player player@gitmissions.local "2025-09-03T09:00:00" "fix: add hardening step to web image [IMG-101]"
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/sh
# gm-hook: pre-commit - no trailing whitespace in HCL templates
bad=""
for f in $(git diff --cached --name-only --diff-filter=AM | grep '\.hcl$'); do
  if git show ":$f" | grep -qE '[[:space:]]+$'; then bad="$bad $f"; fi
done
if [ -n "$bad" ]; then echo "pre-commit: trailing whitespace in:$bad"; exit 1; fi
EOF
cat > .git/hooks/commit-msg <<'EOF'
#!/bin/sh
# gm-hook: commit-msg - conventional subject with a ticket
if ! head -n1 "$1" | grep -qE '^(feat|fix|chore|docs): .+ \[IMG-[0-9]+\]$'; then
  echo "commit-msg: subject must look like 'fix: text [IMG-123]'"; exit 1
fi
EOF
cat > .git/hooks/pre-push <<'EOF'
#!/bin/sh
# gm-hook: pre-push - tests must pass
sh ./test.sh || { echo "pre-push: template tests failed, push aborted"; exit 1; }
EOF
chmod +x .git/hooks/pre-commit .git/hooks/commit-msg .git/hooks/pre-push
git config core.hooksPath .git/hooks
printf 'source "amazon-ebs" "db" {  \n  provisioner = "scripts/postgres.sh"\t\n}\n' > db.pkr.hcl
printf '#!/bin/sh\napt-get install -y postgresql\n' > scripts/postgres.sh
git add db.pkr.hcl scripts/postgres.sh
