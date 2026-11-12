#!/usr/bin/env bash
set -euo pipefail
SANDBOX="$1"
cd "$SANDBOX"

git init -q -b main
git config user.name "Player"
git config user.email "player@gitmissions.local"
git config commit.gpgsign false

export GIT_AUTHOR_NAME="Yuki" GIT_AUTHOR_EMAIL="yuki@weathercli.example"
export GIT_COMMITTER_NAME="Yuki" GIT_COMMITTER_EMAIL="yuki@weathercli.example"
export GIT_AUTHOR_DATE="2025-07-08T12:00:00" GIT_COMMITTER_DATE="2025-07-08T12:00:00"

cat > weather.py <<'EOF'
import os
KEY = os.environ.get("WEATHER_API_KEY", "")
print("forecast for Osaka: sunny")
EOF
printf 'requests==2.32.3\n' > requirements.txt
printf 'WEATHER_API_KEY=\n' > .env.example
mkdir logs && touch logs/.gitkeep
git add .
git commit -q -m "Weather CLI skeleton"

# Files created while working that must never be committed
printf 'WEATHER_API_KEY=9f3c1d7ab2e84c55\n' > .env
mkdir -p __pycache__ dist
printf 'compiled\n' > __pycache__/weather.cpython-312.pyc
printf '2025-07-08 GET /forecast 200\n' > logs/app.log
printf '2025-07-08 retry 2\n' > debug.log
printf 'tarball\n' > dist/weather-0.1.tar.gz
