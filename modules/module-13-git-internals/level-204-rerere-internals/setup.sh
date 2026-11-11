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

git config rerere.enabled true
mkdir terraform
cat > terraform/cluster.tf <<'EOF'
resource "k8s_cluster" "main" {
  name       = "prod"
  node_count = 3
  region     = "eu-west-1"
}
EOF
cat > terraform/alerts.tf <<'EOF'
alert "cpu" {
  threshold = 80
  window    = "5m"
}
EOF
git add -A; ci Ola ola@plat.dev "2025-04-01T09:00:00" "Prod cluster and cpu alert"
git switch -q -c feature/autoscale
cat > terraform/cluster.tf <<'EOF'
resource "k8s_cluster" "main" {
  name       = "prod"
  min_nodes  = 3
  max_nodes  = 9
  region     = "eu-west-1"
}
EOF
sed -i.bak 's/threshold = 80/threshold = 70/' terraform/alerts.tf; rm terraform/alerts.tf.bak
git add -A; ci Ola ola@plat.dev "2025-04-08T09:00:00" "Enable autoscaling and a stricter cpu alert"
git switch -q main
sed -i.bak 's/node_count = 3/node_count = 5/' terraform/cluster.tf
sed -i.bak 's/threshold = 80/threshold = 90/' terraform/alerts.tf; rm terraform/*.bak
git add -A; ci Pia pia@plat.dev "2025-04-09T09:00:00" "Scale prod to five nodes, relax cpu alert"
git merge feature/autoscale >/dev/null 2>&1 || true
cat > terraform/cluster.tf <<'EOF'
resource "k8s_cluster" "main" {
  name       = "prod"
  min_nodes  = 5
  max_nodes  = 9
  region     = "eu-west-1"
}
EOF
git add terraform/cluster.tf
git rerere >/dev/null 2>&1
git merge --abort
