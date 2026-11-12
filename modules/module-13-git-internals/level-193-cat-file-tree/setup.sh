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

mkdir -p playbooks/roles/web playbooks/roles/db
printf -- '- hosts: all\n  roles: [web, db]\n' > playbooks/site.yml
printf '#!/bin/sh\nansible-playbook site.yml --tags web\n' > playbooks/deploy.sh; chmod +x playbooks/deploy.sh
printf -- '- name: install nginx\n  package: name=nginx\n' > playbooks/roles/web/tasks.yml
printf -- '- name: install postgres\n  package: name=postgresql\n' > playbooks/roles/db/tasks.yml
ln -s site.yml playbooks/latest.yml
git add -A; ci Ivo ivo@hosting.dev "2025-04-01T10:00:00" "Playbooks for web and database roles"
printf -- '- name: tune nginx workers\n  lineinfile: path=/etc/nginx/nginx.conf line="worker_processes auto;"\n' >> playbooks/roles/web/tasks.yml
printf '#!/bin/sh\nansible-playbook site.yml --tags web,db --check\n' > playbooks/deploy.sh
git add -A; ci Ivo ivo@hosting.dev "2025-04-10T10:00:00" "Tune nginx workers and add dry-run to deploy"
good=$(git rev-parse HEAD:playbooks)
printf '#!/bin/sh\nansible-playbook site.yml --tags db --limit nobody\n' > playbooks/deploy.sh
git add -A; ci Noa noa@hosting.dev "2025-04-18T10:00:00" "deploy: restrict hosts"
git rm -rq playbooks
ci Noa noa@hosting.dev "2025-04-19T10:00:00" "cleanup: remove playbooks directory"
printf 'tree: %s\n' "$good" > RESTORE.txt
