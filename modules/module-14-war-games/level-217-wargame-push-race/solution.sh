#!/usr/bin/env bash
set -e
git fetch -q origin
git rebase origin/main >/dev/null 2>&1 || true
cat > dags/nightly.py <<'EOF'
from airflow import DAG

schedule = "30 1 * * *"
retries = 2
EOF
git add dags/nightly.py
GIT_EDITOR=true git rebase --continue >/dev/null 2>&1 || true
printf 'apache-airflow\npandas\npsycopg2\nrequests\n' > requirements.in
./gen-lock.sh
git add requirements.in requirements.lock
GIT_EDITOR=true git rebase --continue >/dev/null
git push -q origin main
