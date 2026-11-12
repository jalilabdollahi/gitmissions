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
mkdir -p inventory/group_vars
printf 'env: prod\nntp_server: ntp.corp.example\ndns_search: corp.example\nproxy: none\nmetrics_port: 9100\nlog_retention_days: 30\n' > inventory/group_vars/all.yml
printf '[db]\ndb1\ndb2\n' > inventory/hosts.ini
git add -A; ci Player player@gitmissions.local "2025-06-02T09:00:00" "inventory: base groups"
printf '[web]\nweb1\n' >> inventory/hosts.ini
git add -A; ci Player player@gitmissions.local "2025-06-03T09:00:00" "inventory: add web hosts"
git push -q origin main 2>/dev/null
cd "$SANDBOX"
git clone -q origin.git jonas 2>/dev/null
git clone -q origin.git ines 2>/dev/null
git clone -q origin.git tomas 2>/dev/null
( cd ines; printf '[monitoring]\nmon1\n' >> inventory/hosts.ini; git add -A; ci Ines ines@corp.dev "2025-06-04T09:00:00" "inventory: add monitoring group"; git push -q origin main 2>/dev/null )
( cd tomas; git pull -q origin main 2>/dev/null; printf '[backup]\nbak1\n' >> inventory/hosts.ini; git add -A; ci Tomas tomas@corp.dev "2025-06-05T09:00:00" "inventory: add backup host"; git push -q origin main 2>/dev/null )
( cd ines; git pull -q origin main 2>/dev/null; sed -i.bak 's/ntp_server: ntp.corp.example/ntp_server: ntp2.corp.example/' inventory/group_vars/all.yml; rm inventory/group_vars/all.yml.bak
  git add -A; ci Ines ines@corp.dev "2025-06-06T09:00:00" "inventory: switch NTP to ntp2"; git push -q origin main 2>/dev/null )
cd work
git pull -q origin main 2>/dev/null
sed -i.bak 's/log_retention_days: 30/log_retention_days: 90/' inventory/group_vars/all.yml; rm inventory/group_vars/all.yml.bak
git add -A; ci Player player@gitmissions.local "2025-06-07T09:00:00" "inventory: raise log retention to 90 days"
cd "$SANDBOX/jonas"
sed -i.bak 's/ntp_server: ntp.corp.example/ntp_server: time.corp.example/' inventory/group_vars/all.yml; rm inventory/group_vars/all.yml.bak
git add -A; ci Jonas jonas@corp.dev "2025-06-08T09:00:00" "inventory: move NTP to time server"
git push -q --force origin main 2>/dev/null
cd "$SANDBOX/work"
git fetch -q origin
git reset -q --hard origin/main
