#!/usr/bin/env bash
set -e
git reset --soft HEAD~1
sed -i.bak 's/^password = .*/password = ${SMTP_PASSWORD}/' config/smtp.ini && rm config/smtp.ini.bak
git add config/smtp.ini
git commit -q -m "Add SMTP settings for the report mailer"
