#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main seedly
cd seedly
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
printf '.env.local\n' > .gitignore
printf 'CREATE TABLE users (id INT);\n' > schema.sql
git add . && git commit -q -m "Initial schema"
git switch -q -c release/1.0
printf -- '-- v1 seed\n' > seed_data.sql
git add . && git commit -q -m "Ship v1 seed data"
git switch -q main
printf 'CREATE TABLE users (id INT, email TEXT);\n' > schema.sql
printf -- 'INSERT INTO users VALUES (1);  -- new seed\n' > seed_data.sql
printf 'DB_PASSWORD=hunter2\n' > .env.local
