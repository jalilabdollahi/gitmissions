#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

# ci NAME EMAIL DATE MESSAGE : commit staged changes as another author at a fixed date
ci() { GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$2" GIT_AUTHOR_DATE="$3" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$2" GIT_COMMITTER_DATE="$3" git commit -q -m "$4"; }

git init -q --bare -b main origin.git
git clone -q origin.git ines 2>/dev/null
cd ines
git config user.name Ines; git config user.email ines@orbit.dev; git config commit.gpgsign false
mkdir deploy
printf 'apiVersion: v2\nname: orbit\nversion: 3.0.0\n' > Chart.yaml
printf 'appVersion: 3.0.0\ntls:\n  minVersion: "1.0"\n  ciphers: default\nreplicas: 3\n' > deploy/values.yaml
cat > check.sh <<'EOF'
#!/bin/sh
# repository rules checked before every push
cd "$(dirname "$0")"
if grep -rqE '^(<<<<<<<|=======|>>>>>>>)' deploy Chart.yaml; then echo "conflict markers"; exit 1; fi
if [ -e artifacts.txt ]; then echo "build artifacts must not be committed"; exit 1; fi
cv=$(sed -n 's/^version: //p' Chart.yaml)
av=$(sed -n 's/^appVersion: //p' deploy/values.yaml)
if [ "$cv" != "$av" ]; then echo "Chart version $cv differs from appVersion $av"; exit 1; fi
echo "checks ok"
EOF
chmod +x check.sh
git add -A; ci Ines ines@orbit.dev "2026-01-05T09:00:00" "Orbit platform 3.0 baseline"
git push -q origin main 2>/dev/null
git switch -q -c release/3.0
sed -i.bak 's/minVersion: "1.0"/minVersion: "1.2"/' deploy/values.yaml; rm deploy/values.yaml.bak
git add -A; ci Ines ines@orbit.dev "2026-01-12T09:00:00" "release: freeze tls config"
sed -i.bak 's/3.0.0/3.0.2/' Chart.yaml deploy/values.yaml; rm Chart.yaml.bak deploy/values.yaml.bak
git add -A; ci Tomas tomas@orbit.dev "2026-01-14T09:00:00" "release: bump chart to 3.0.2"
git push -q origin release/3.0 2>/dev/null
cd "$SANDBOX"
git clone -q origin.git work 2>/dev/null
cd work
git config user.name "Player"; git config user.email "player@gitmissions.local"; git config commit.gpgsign false
git switch -q -c hotfix/tls origin/main
sed -i.bak -e 's/minVersion: "1.0"/minVersion: "1.3"/' -e 's/ciphers: default/ciphers: modern/' deploy/values.yaml; rm deploy/values.yaml.bak
git add -A; ci Player player@gitmissions.local "2026-01-15T09:00:00" "tls: require 1.3 and modern ciphers"
sed -i.bak 's/3.0.0/3.0.1/' Chart.yaml deploy/values.yaml; rm Chart.yaml.bak deploy/values.yaml.bak
printf 'hsts: true\n' >> deploy/values.yaml
git add -A; ci Player player@gitmissions.local "2026-01-15T11:00:00" "tls: add hsts and bump to 3.0.1"
git switch -q main
git branch -q -D hotfix/tls
cd "$SANDBOX"
git clone -q origin.git bot 2>/dev/null
cd bot
git config user.name ci-bot; git config user.email bot@orbit.dev; git config commit.gpgsign false
git switch -q -c release/3.0 origin/release/3.0
git reset -q --hard origin/main
printf 'build 4711\n' > artifacts.txt
git add -A; ci ci-bot bot@orbit.dev "2026-01-16T08:00:00" "ci: rebuild artifacts"
git push -q --force origin release/3.0 2>/dev/null
cd "$SANDBOX/work"
git fetch -q origin
cat > .git/hooks/pre-push <<'EOF'
#!/bin/sh
# gm-hook: pre-push - repository rules must hold
sh ./check.sh || { echo "pre-push: check.sh failed, push aborted"; exit 1; }
EOF
chmod +x .git/hooks/pre-push
git config core.hooksPath .git/hooks
