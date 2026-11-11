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
mkdir -p scraper
printf 'import urllib.request\n\ndef fetch(symbol):\n    url = "https://quotes.example.test/v1/%s" % symbol\n    return urllib.request.urlopen(url).read()\n' > scraper/quotes.py
ci Dana "2025-06-02T09:00:00" "Scrape quotes for one symbol"
printf 'API_TOKEN = "tk_live_51Hx9qRzV"\nTIMEOUT = 10\n' > scraper/settings.py
ci Ravi "2025-06-03T16:40:00" "Add settings module for the quote API"
printf 'WATCHLIST = ["ACME", "GLOBEX", "INITECH"]\n' > scraper/watchlist.py
ci Dana "2025-06-04T10:00:00" "Add default watchlist"
sed -i.bak 's/tk_live_51Hx9qRzV/tk_live_77AbQ0mNs/' scraper/settings.py && rm scraper/settings.py.bak
ci Ravi "2025-06-06T11:00:00" "Rotate API token after quota warning"
printf '# Tokens\nRotate the API token every quarter (see settings).\n' > TOKENS.md
ci Mei "2025-06-09T09:15:00" "Document token rotation policy"
printf 'import os\nAPI_TOKEN = os.environ["QUOTE_API_TOKEN"]\nTIMEOUT = 10\n' > scraper/settings.py
ci Mei "2025-06-10T13:00:00" "Read the API key from the environment"
printf 'def parse(blob):\n    return [line.split(",") for line in blob.decode().splitlines()]\n' > scraper/parse.py
ci Tom "2025-06-12T14:00:00" "Parse CSV quote responses"
