#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main profilr
cd profilr
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
mkdir api db
printf 'CREATE TABLE users (id INT);\n' > db/001_users.sql && c "Create users table"
git switch -q -c feature/avatars
printf 'def upload(user, blob):\n    return "INSERT INTO avatars"\n' > api/avatar.py && c "Add avatar upload endpoint"
printf 'CREATE TABLE avatars (user_id INT, blob BLOB);\n' > db/002_avatars.sql && c "Create avatars table migration"
printf 'def thumb(blob):\n    return blob[:64]\n' > api/thumbs.py && c "Add avatar thumbnails"
