#!/usr/bin/env bash
set -e
git merge HEAD@{1} >/dev/null || true
cat > inventory/group_vars/all.yml <<'EOF'
env: prod
ntp_server: ntp2.corp.example
dns_search: corp.example
proxy: none
metrics_port: 9100
log_retention_days: 90
EOF
git add inventory/group_vars/all.yml
git commit -q --no-edit
git push -q origin main
git -C ../origin.git config receive.denyNonFastForwards true
