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

mkdir modules config
printf 'terraform {\n  required_version = ">= 1.6"\n}\n' > main.tf
git add -A; ci Wanda wanda@billing.dev "2025-12-01T09:00:00" "Terraform base for billing"
printf 'AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE\nAWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY\n' > config/prod.env
git add -A; ci Wanda wanda@billing.dev "2025-12-02T09:00:00" "Add prod credentials file"
printf 'resource "aws_s3_bucket" "invoices" {}\n' > modules/s3.tf
git add -A; ci Hal hal@billing.dev "2025-12-03T09:00:00" "Add S3 bucket module"
printf 'resource "aws_iam_role" "billing" {}\n' > modules/iam.tf
git add -A; ci Hal hal@billing.dev "2025-12-04T09:00:00" "Add IAM role module"
printf 'resource "aws_cloudwatch_metric_alarm" "cpu" {\n  threshold = 80\n}\n' > alarms.tf
git add -A; ci Wanda wanda@billing.dev "2025-12-05T09:00:00" "Add CloudWatch alarms"
sed -i.bak 's/threshold = 80/threshold = 85/' alarms.tf; rm alarms.tf.bak
git add -A; ci Hal hal@billing.dev "2025-12-08T09:00:00" "Tune alarm thresholds"
cat > .git/hooks/pre-commit <<'EOF'
#!/bin/sh
# gm-hook: secret-scan - refuse commits while an AWS key is tracked
if git grep -qE 'AKIA[0-9A-Z]{16}' -- . ':!*.example' 2>/dev/null; then
  echo "pre-commit: AWS access key found in tracked files, aborting"
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit
git config core.hooksPath .git/hooks
