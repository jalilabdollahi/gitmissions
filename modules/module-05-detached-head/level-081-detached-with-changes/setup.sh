#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main pawfinder
cd pawfinder
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
printf 'CREATE TABLE pets (id INT, name TEXT);\n' > schema.sql
printf 'ideas:\n' > notes.txt && c "Create pets table"
printf 'CREATE TABLE owners (id INT);\n' >> schema.sql && c "Add owners table"
git tag v0.9
printf 'CREATE INDEX pets_name ON pets(name);\n' >> schema.sql && c "Index pet names"
git switch -q --detach v0.9
printf 'CREATE TABLE pets (id INT, name TEXT, vaccinated BOOLEAN);\nCREATE TABLE owners (id INT);\n' > schema.sql
git add schema.sql
printf 'ideas:\n- photo gallery\n' > notes.txt
