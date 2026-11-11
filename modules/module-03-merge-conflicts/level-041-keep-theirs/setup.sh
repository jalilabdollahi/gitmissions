#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

d() { export GIT_AUTHOR_DATE="$1" GIT_COMMITTER_DATE="$1"; }
who() { export GIT_AUTHOR_NAME="$1" GIT_AUTHOR_EMAIL="$1@toursapp.example" GIT_COMMITTER_NAME="$1" GIT_COMMITTER_EMAIL="$1@toursapp.example"; }

mkdir lang
cat > lang/de.json <<'EOF'
{
  "welcome": "Willkommen",
  "map": "Karte",
  "tickets": "Eintrittskarten",
  "contact": "Kontakt"
}
EOF
cat > app.ini <<'EOF'
[server]
api_url = https://api.tours.example/v1
timeout = 10
EOF
printf 'Tourist info app\n' > README.md
who liam; git add . && d 2025-04-01T09:00:00; git commit -q -m "Tourist info app with German strings"

git switch -q -c german-review
who eva
cat > lang/de.json <<'EOF'
{
  "welcome": "Herzlich willkommen",
  "map": "Stadtplan",
  "tickets": "Eintrittskarten online kaufen",
  "contact": "Kontakt"
}
EOF
cat > app.ini <<'EOF'
[server]
api_url = https://staging.tours.example/v2
timeout = 10
EOF
d 2025-04-08T09:00:00; git commit -q -am "Native-speaker review of German strings (and staging API for testing)"

git switch -q main
who liam
cat > lang/de.json <<'EOF'
{
  "welcome": "Willkommen",
  "map": "Plan",
  "tickets": "Tickets",
  "contact": "Kontakt"
}
EOF
cat > app.ini <<'EOF'
[server]
api_url = https://api.tours.example/v2
timeout = 10
EOF
d 2025-04-09T09:00:00; git commit -q -am "Machine-translated shortcuts and production API v2"
