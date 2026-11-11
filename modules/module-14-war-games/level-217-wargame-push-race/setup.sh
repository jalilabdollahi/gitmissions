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
mkdir dags
printf 'from airflow import DAG\n\nschedule = "0 2 * * *"\nretries = 2\n' > dags/nightly.py
printf 'apache-airflow\npsycopg2\n' > requirements.in
cat > gen-lock.sh <<'EOF'
#!/bin/sh
# derives requirements.lock from requirements.in
cd "$(dirname "$0")"
{
  echo "# generated from requirements.in checksum $(sort requirements.in | cksum | cut -d' ' -f1)"
  sort requirements.in | sed 's/$/ --hash=ok/'
} > requirements.lock
EOF
chmod +x gen-lock.sh; ./gen-lock.sh
git add -A; ci Elio elio@dags.dev "2025-10-01T09:00:00" "dag: nightly pipeline and pinned dependencies"
git push -q origin main 2>/dev/null
cd "$SANDBOX"
git clone -q origin.git bob 2>/dev/null
cd work
sed -i.bak 's/0 2 \* \* \*/30 1 * * */' dags/nightly.py; rm dags/nightly.py.bak
git add -A; ci Player player@gitmissions.local "2025-10-06T09:00:00" "dag: nightly at 01:30"
printf 'requests\n' >> requirements.in; ./gen-lock.sh
git add -A; ci Player player@gitmissions.local "2025-10-07T09:00:00" "deps: add requests"
printf 'from airflow import DAG\n\nschedule = "0 6 * * 0"\n' > dags/cleanup.py
git add -A; ci Player player@gitmissions.local "2025-10-08T09:00:00" "dag: add cleanup job"
cd "$SANDBOX/bob"
sed -i.bak 's/0 2 \* \* \*/0 3 * * */' dags/nightly.py; rm dags/nightly.py.bak
git add -A; ci Bob bob@dags.dev "2025-10-06T10:00:00" "dag: nightly at 03:00"
printf 'pandas\n' >> requirements.in; ./gen-lock.sh
git add -A; ci Bob bob@dags.dev "2025-10-06T11:00:00" "deps: add pandas"
git push -q origin main 2>/dev/null
