#!/usr/bin/env bash
set -e
git merge feature/autoscale || true
cat > terraform/alerts.tf <<'EOF'
alert "cpu" {
  threshold = 70
  window    = "5m"
}
EOF
git add terraform
git commit -qm "Merge feature/autoscale"
for d in "$(git rev-parse --git-path rr-cache)"/*/; do
  if cmp -s "$d/postimage" terraform/cluster.tf; then basename "$d" > rr.txt; fi
done
