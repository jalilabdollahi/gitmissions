#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

# ci <author> <iso-date> <message>: stage everything and commit as that author
ci() {
  local who; who=$(printf %s "$1" | tr 'A-Z ' 'a-z.')
  git add -A
  GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$who@example.dev" GIT_AUTHOR_DATE="$2" GIT_COMMITTER_DATE="$2" git commit -q -m "$3"
}
printf '# Report mailer\nSends the nightly P&L report.\n' > README.md
ci Dana "2025-11-03T09:00:00" "Report mailer skeleton"
mkdir config
printf '[smtp]\nhost = smtp.corp.example\nport = 587\nuser = reports\npassword = S3cretPass-8841\n' > config/smtp.ini
printf 'import configparser\n\ndef load():\n    cfg = configparser.ConfigParser()\n    cfg.read("config/smtp.ini")\n    return cfg["smtp"]\n' > mailer.py
ci Ravi "2025-11-04T10:00:00" "Add SMTP settings for the report mailer"
git rev-parse HEAD~1 > .git/gm-base
