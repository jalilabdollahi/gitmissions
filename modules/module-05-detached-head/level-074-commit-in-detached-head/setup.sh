#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main signflow
cd signflow
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false
c() { git add -A && git commit -q -m "$1"; }
mkdir signup
printf 'module.exports = (s) => /^[a-z0-9._-]+@[a-z0-9.-]+\\.[a-z]{2,}$/.test(s);\n' > signup/validate.js && c "Validate signup emails"
printf 'module.exports = () => "Welcome!";\n' > signup/welcome.js && c "Add welcome message"
git tag v3.2.0
printf 'module.exports = { variant: "B" };\n' > signup/banner.js && c "Add pricing banner experiment"
git switch -q --detach v3.2.0
